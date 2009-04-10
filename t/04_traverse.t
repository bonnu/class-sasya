#!/usr/bin/env perl
use strict;
use warnings;
use Test::More 'no_plan';

{
    package Foo;
    use Class::Sasya;

    has stash => (is => 'rw', default => sub { '' });
    
    hooks qw/
        a b c d e f
    /;
}

{
    package Foo::A;
    use Class::Sasya::Plugin;

    hook_to '/a' => sub { $_[0]->stash($_[0]->stash . 'a') };

    package Foo::B;
    use Class::Sasya::Plugin;

    hook_to '/b' => sub { $_[0]->stash($_[0]->stash . 'b') };

    package Foo::C;
    use Class::Sasya::Plugin;

    hook_to '/c' => sub { $_[0]->stash($_[0]->stash . 'c') };

    package Foo::D;
    use Class::Sasya::Plugin;

    hook_to '/d' => sub { $_[0]->stash($_[0]->stash . 'd') };

    package Foo::E;
    use Class::Sasya::Plugin;

    hook_to '/e' => sub { $_[0]->stash($_[0]->stash . 'e') };
}

my $foo_1 = Foo->bootstrap;

is $foo_1->stash, q//;

{
    package Foo;

    plugins '+::*';
}

my $foo_2 = Foo->bootstrap;

is $foo_2->stash, q/abcde/;

{
    package Foo::C::Die;
    use Class::Sasya::Plugin;

    hook_to '/c' => sub { die };
}

{
    package Foo;

    plugins '+::C::Die';
}

my $foo_3 = Foo->new;

eval { $foo_3->bootstrap };

is $foo_3->stash, q/abc/;

$foo_3->stash(q{});

eval { $foo_3->bootstrap };

is $foo_3->stash, q/abc/;
