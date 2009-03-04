package Foo::Plugin::Spaces;

use Mouse::Role;
=pod
use strict;
use warnings;
use Class::Sasya::Plugin;

hook_to
    'main/phase1/sub3' => 'space',
    'main/phase2/sub3' => 'space',
;

sub space {
    my $self = shift;
    $self->stash->{caption} .= ' ';
}
=cut

1;

__END__
