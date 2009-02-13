package Foo;

use strict;
use warnings;
use Class::Sasya;
use Class::Sasya::Hook::Catch;
use Class::Sasya::Hook::EvalScope;

hooks
    'initialize',
#   hook('main' => 'EvalScope') => [
    'main' => [
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
#   hook('catch' => 'Catch'),
    'catch',
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
