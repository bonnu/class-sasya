#!/usr/bin/env perl
use strict;
use warnings;
use Test::More 'no_plan';
use FindBin::libs;
use lib "$FindBin::Bin/lib";

{
    package Foo;

    use Class::Sasya;

    has message => (
        is      => 'rw',
        isa     => 'Str',
        default => 'hello world',
    );

    hooks 
        'initialize',
        hook('main' => 'EvalScope') => [
            'phase1' => [qw/
                sub1
                sub2
                sub3
            /],
            'phase2' => [qw/
                sub1
                sub2
                sub3
            /],
            'phase3' => [qw/
                sub1
                sub2
                sub3
            /],
        ],
        hook('catch' => 'Catch'),
        'finalize',
    ;

    no Class::Sasya;
}

use Data::Dumper;

my $foo = Foo->new;

print Dumper($foo);

print Dumper(Foo->meta);
