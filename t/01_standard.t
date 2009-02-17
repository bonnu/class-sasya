#!/usr/bin/env perl
use strict;
use warnings;
use Test::More 'no_plan';
use FindBin::libs;
use lib "$FindBin::Bin/lib";

BEGIN {
    package Bar;

    use Foo;

    __PACKAGE__->a('setup at Bar');

    __PACKAGE__->b(qw/1 2 3 4/);

    __PACKAGE__->c(qw/1 2 3 4/);

    __PACKAGE__->g({ foo => 1, bar => 2, baz => 3 });

    package Baz;

    push our @ISA, 'Bar';

    __PACKAGE__->a('setup at Baz');
}

# test of configure : Bar
{
    is(Bar->a, 'setup at Bar');
    is_deeply(Bar->b, [qw/ 1 2 3 4 /]);
    is_deeply(Bar->c, { 1 => 2, 3 => 4 });
    is_deeply(Bar->g, { foo => 1, bar => 2, baz => 3 });
}

# test of configure : Baz
{
    is(Baz->a, 'setup at Baz');
    is_deeply(Baz->g, { foo => 1, bar => 2, baz => 3 });
}

{
    my $obj = Bar->new;

    $obj->bootstrap;

    is $obj->stash->{caption}, 'hello world ! setup at Bar';
}

{
    my $obj = Baz->new;

    $obj->bootstrap;

    is $obj->stash->{caption}, 'hello world ! setup at Baz';
}
