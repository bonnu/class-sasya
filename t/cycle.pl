#!/usr/bin/env perl

use strict;
use warnings;
use FindBin::libs;
use Foo;
use Devel::Cycle;

my $foo = Foo->new;

$foo->bootstrap;

print $foo->message, "\n";
print $foo->stash->{caption}, "\n";

find_cycle($foo);

find_cycle(Foo->_root);
