#!/usr/bin/env perl
use strict;
use warnings;
use Test::More 'no_plan';
use FindBin::libs;
use lib "$FindBin::Bin/lib";
use Foo;

# test of configure : Foo
{
    is(Foo->a, 'setup at Foo');
    is_deeply(Foo->b, [qw/ 1 2 3 4 /]);
    is_deeply(Foo->c, { 1 => 2, 3 => 4 });
    is_deeply(Foo->g, { foo => 1, bar => 2, baz => 3 });
}

# test of configure : Bar
{
    is(Bar->a, 'setup at Bar');
    is_deeply(Bar->g, { foo => 1, bar => 2, baz => 3 });
}

{
    my $obj = Foo->new;

    $obj->bootstrap;

    is $obj->stash->{caption}, 'hello world ! setup at Foo';
}

{
    my $obj = Bar->new;

    $obj->bootstrap;

    is $obj->stash->{caption}, 'hello world ! setup at Bar';
}
