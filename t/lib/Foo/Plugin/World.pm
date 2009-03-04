package Foo::Plugin::World;

use Mouse::Role;
=pod
use strict;
use warnings;
use Class::Sasya::Plugin;

hook_to 'main/phase2/sub1' => 'world';

sub world {
    my $self = shift;
    $self->stash->{caption} .= 'world';
}
=cut

1;

__END__
