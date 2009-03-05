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

is_deeply(\@Foo::ISA, [ 'Mouse::Object' ]);

{
    package Bar;

    use Foo;
}

=pod
my $bar = Bar->new;

print Dumper($bar);

print Dumper(\@Bar::ISA);

use B::Deparse;
my $deparse = B::Deparse->new;
my $body    = $deparse->coderef2text(Foo->can('import'));

print $body;
=cut
