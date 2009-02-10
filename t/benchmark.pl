#!/usr/bin/env perl

use strict;
use warnings;
use FindBin::libs;
use Benchmark qw/cmpthese timethese/;

use Foo;

cmpthese(10000, {
    'Class::Sasya' => sub { Foo->bootstrap },
});
