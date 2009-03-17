#!/usr/bin/env perl
use strict;
use warnings;
use FindBin::libs;

package Foo;
use Mouse;

has foo => (is => 'rw');

__PACKAGE__->meta->make_immutable(inline_destructor => 1);

package Bar;
use strict;
use warnings;
use base qw/Class::Accessor::Fast/;

__PACKAGE__->mk_accessors(qw/bar/);

package Baz;
use Class::Sasya;

has baz => (is => 'rw');

__PACKAGE__->meta->make_immutable(inline_destructor => 1);

package main;
# use 5.010;
use strict;
use warnings;

use Benchmark qw(timethese);

my $foo = Foo->new();
my $bar = Bar->new();
my $baz = Baz->new();

timethese(undef, {
    mouse_new => sub {
        my $x = Foo->new();
    },
    caf_new => sub {
        my $x = Bar->new();
    },
    sasya_new => sub {
        my $x = Baz->new();
    },
    mouse_call => sub {
        $foo->foo(10);
    },
    caf_call => sub {
        $bar->bar(10);
    },
    sasya_call => sub {
        $baz->baz(10);
    },
});
