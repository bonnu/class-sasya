#!/usr/bin/env perl

use strict;
use warnings;
use GTop;
use Devel::Cycle;
use FindBin;
use lib "$FindBin::Bin/lib";
use Foo;

my $gtop = GTop->new;
my $obj  = Foo->new;
my @size = ( 0 );

for (1 .. 10000) {
    {
        local *STDOUT; open STDOUT, '>', \(my $out = q{});
        local *STDERR; open STDERR, '>', \(my $err = q{});
        $obj->bootstrap;
    }
    my $size = $gtop->proc_mem($$)->size;
    push @size, $size if $size[$#size] < $size;
    last if 10 < @size;
}

shift @size;

print join(' ==> ', @size), "\n\n";

find_cycle($obj);
