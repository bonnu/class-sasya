package Foo::Plugin::Stash;

use Class::Sasya::Plugin;

has stash => (
    is      => 'rw',
    lazy    => 1,
    default => sub { +{} },
);

1;

__END__
