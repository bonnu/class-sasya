package Foo::Plugin::Stash;

use Class::Sasya::Plugin;

has stash => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { +{} },
);

1;

__END__
