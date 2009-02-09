package Foo;

use strict;
use warnings;
use Class::Sasya;

hooks
    'phase0',
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
;

plugins
    namespace => [qw/
        +::Plugin::*
    /],
    ignore    => [qw/
        +::Plugin::IgnoreModule
    /],
;

{
    __PACKAGE__->a('setup at Foo');

    __PACKAGE__->b(qw/1 2 3 4/);

    __PACKAGE__->c(qw/1 2 3 4/);

    __PACKAGE__->g({ foo => 1, bar => 2, baz => 3 });
}

package Bar;

push our @ISA, 'Foo';

__PACKAGE__->a('setup at Bar');

1;

__END__
