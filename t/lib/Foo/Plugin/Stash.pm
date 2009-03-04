package Foo::Plugin::Stash;

use Mouse::Role;
=pod
use strict;
use warnings;
use Class::Sasya::Plugin;

hook_to 'initialize' => sub { shift->stash({}) };

__PACKAGE__->make_accessors qw/stash/;
=cut

1;

__END__
