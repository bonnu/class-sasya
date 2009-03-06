#!/usr/bin/env perl
use strict;
use warnings;
use Test::More 'no_plan';
use FindBin::libs;
use lib "$FindBin::Bin/lib";
use Data::Dumper;

use Foo;

my $foo = Foo->new;

$foo->bootstrap;

print Dumper($foo);

print Dumper(\@Foo::ISA);

print Dumper($foo->meta);

is_deeply(\@Foo::ISA, [ 'Mouse::Object' ]);

{
    package Bar;

    use base qw/Foo/;
}

my $bar = Bar->new;

$bar->bootstrap;

print Dumper($bar);

print Dumper(\@Bar::ISA);
