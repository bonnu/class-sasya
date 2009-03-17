package TestPlugin::Hello;

use Class::Sasya::Plugin;

has hello => (
    is      => 'ro',
    default => 'Hello!',
);

1;

__END__
