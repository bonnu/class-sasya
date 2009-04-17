#!/usr/bin/env perl
use strict;
use warnings;
use Test::More 'no_plan';

# example :

{
    package Case::ContentFilter;
    use Class::Sasya;

    hooks
        'initialize',
        'filtering' => [qw/
            before
            main
            after
        /],
        'finalize',
    ;

    has type => (is  => 'rw', isa => 'Str');

    hook_to '/filtering/before' => sub {
        my ($self, $content) = @_;
    };
}

{
    package Case::ContentFilter::
    use Class::Sasya::Plugin;
}
{
    package Case::ContentFilter::
    use Class::Sasya::Plugin;
}
{
    package Case::ContentFilter::
    use Class::Sasya::Plugin;
}
