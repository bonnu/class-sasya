package Foo::Plugin::Stash;

use strict;
use warnings;
use Class::Sasya::Plugin;

hook_to 'phase0' => sub { shift->stash({}) };

__PACKAGE__->make_accessors qw/stash/;

1;

__END__
