package Foo::Plugin::Hello;

use Mouse::Role;

=pod
use Class::Sasya::Plugin;

hook_to 'main/phase1/sub1' => 'hello';

sub hello {
    my $self = shift;
    $self->stash->{caption} .= 'hello';
}
=cut

1;

__END__
