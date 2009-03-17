package TestPlugin::World;

use Class::Sasya::Plugin;

requires 'hello';

has world => (
    is      => 'ro',
    default => 'World!',
);

sub say_hello_world {
    my $self  = shift;
    my $hello = substr $self->hello, 0, -1;
    $hello . ' ' . lcfirst $self->world;
}

1;

__END__
