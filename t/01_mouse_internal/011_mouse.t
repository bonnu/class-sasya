#!/usr/bin/env perl
use strict;
use warnings;
use Test::More 'no_plan';
use Data::Dumper;

our $TEST_EXTEND_CLASS = 'Exporter';

BEGIN {
    package Foo;

    main::use_ok('Mouse');
}

{
    is_deeply
        \@Mouse::EXPORT,
        [qw/ extends has before after around override super blessed confess with /];
}

my $foo = Foo->new;

isa_ok  +$foo, 'Mouse::Object';
ok      !$foo->can($TEST_EXTEND_CLASS);
can_ok  +$foo, 'meta';
isa_ok  +$foo->meta, 'Mouse::Meta::Class';

{
    package Foo;

    extends $main::TEST_EXTEND_CLASS;
}

isa_ok  +$foo, $TEST_EXTEND_CLASS;

{
    package Foo;

    has accessor_a => (
        is      => 'rw',
        isa     => 'Str',
    );
}

can_ok  +$foo, 'accessor_a';
ok      $foo->accessor_a('This is accessor_a.');
is      $foo->accessor_a, 'This is accessor_a.';
