package Foo;

use Class::Sasya;

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

plugins
    namespace => [qw/
        +::Plugin::*
    /],
    ignore    => [qw/
        +::Plugin::AnError
        +::Plugin::IgnoreModule
    /],
;

class_has name => 'Boofy';

has message => (
    is      => 'rw',
    lazy    => 1,
    default => sub { 'foo bar baz' },
);

no Class::Sasya;

1;

__END__
