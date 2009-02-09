#!/usr/bin/env perl
use strict;
use warnings;
use Test::More 'no_plan';

{
    package TestClass::Plugin::Foo;
    use Class::Sasya::Plugin;
    sub mixture_1 { 1 }

    package TestClass::Plugin::Bar;
    use Class::Sasya::Plugin;
    sub mixture_2 { 1 }

    __PACKAGE__->make_accessors qw/bar/;

    package TestClass::Plugin::Baz;
    sub mixture_3 { 1 } # non_mixture
}

{
    package Foo;
    mixin TestClass::Plugin::Foo;
}

is_deeply(
    Class::Sasya::Class::_methods('Foo'),
    [qw/
        hook_to
        mixture_1
        option
    /],
);

{
    package Foo;
    mixin TestClass::Plugin::Bar;
    # Can't locate object method "mixin"
    eval { mixin TestClass::Plugin::Baz };
}

is_deeply(
    Class::Sasya::Class::_methods('Foo'),
    [qw/
        bar
        hook_to
        mixture_1
        mixture_2
        option
    /],
);
