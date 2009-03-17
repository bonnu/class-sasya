#!/usr/bin/env perl
use strict;
use warnings;
use Test::More 'no_plan';

{
    package Foo;
    use Class::Sasya;

    has hello => (
        is      => 'rw',
        default => 'Hello!',
    );

    has world => (
        is      => 'ro',
        default => 'World!',
    );

    main::isa_ok __PACKAGE__->meta, 'Mouse::Meta::Class';
}

my $foo = Foo->new;

is  $foo->hello, 'Hello!';

$foo->hello(uc $foo->hello);

is  $foo->hello, 'HELLO!';

is  $foo->world, 'World!';

{
    eval { $foo->world(uc $foo->world) };

    ok  1 if ($@);
}
