package Foo::Plugin::World;

use strict;
use warnings;
use Class::Sasya::Plugin;

hook_to 'main/phase2/sub1' => 'world';

sub world {
    my $self = shift;
    $self->stash->{caption} .= 'world';
}

1;

__END__
