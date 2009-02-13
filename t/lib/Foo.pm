package Foo;

use strict;
use warnings;
use Class::Sasya;

hooks
    'initialize',
    scope('main' => 'eval') => [
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
    scope('catch' => 'catch'),
    'finalize',
;

plugins
    namespace => [qw/
        +::Plugin::*
    /],
    ignore    => [qw/
        +::Plugin::AnError
        +::Plugin::IgnoreModule
    /],
;

1;

__END__
