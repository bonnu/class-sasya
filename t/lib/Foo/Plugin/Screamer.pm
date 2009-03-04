package Foo::Plugin::Screamer;

use Mouse::Role;
=pod
use strict;
use warnings;
use Class::Sasya::Plugin;

hook_to 'main/phase3/sub1' => 'screamer';

sub screamer {
    my $self = shift;
    $self->stash->{caption} .= '!';
}
=cut

1;

__END__
