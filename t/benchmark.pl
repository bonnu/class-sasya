#!/usr/bin/env perl

use strict;
use warnings;
use FindBin::libs;
use Benchmark qw/cmpthese timethese/;

BEGIN {
    package Bar;

    use Foo;

    __PACKAGE__->a('setup at Bar');

    __PACKAGE__->b(qw/1 2 3 4/);

    __PACKAGE__->c(qw/1 2 3 4/);

    __PACKAGE__->g({ foo => 1, bar => 2, baz => 3 });
}

cmpthese(10000, {
    'Class::Sasya' => sub { Bar->bootstrap },
});
