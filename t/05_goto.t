#/usr/bin/env perl
use strict;
use warnings;
use Test::More 'no_plan';

{
    package Foo::A;
    use Class::Sasya::Plugin;

    hook_to '/1' => sub { $_[0]->stash($_[0]->stash . '1'); return 1 };

    package Foo::B;
    use Class::Sasya::Plugin;

    hook_to '/2' => sub { $_[0]->stash($_[0]->stash . '2'); return 1 };

    package Foo::C;
    use Class::Sasya::Plugin;

    hook_to '/3' => sub { $_[0]->stash($_[0]->stash . '3'); return 1 };
}

{
    package Foo;
    use Class::Sasya;

    has stash => (is => 'rw', default => sub { '' });
    
    hooks qw/
        1
        2
        3
    /;

    plugins '+::*';

    hook_to '/1' => sub {
        my ($self, $skip_2) = @_;
        if ($skip_2) {
            $self->context->goto('/3');
        }
        return 1;
    };
}

my $foo_1 = Foo->bootstrap;

is $foo_1->stash, q/123/;

my $foo_2 = Foo->bootstrap(1);

is $foo_2->stash, q/13/;
