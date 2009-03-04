package Foo::Plugin::AnError;

use strict;
use warnings;
use Mouse::Role;

=pod
use Class::Sasya::Plugin;

hook_to 'main/phase2' => 'an_error';

sub an_error {
    die 'died on Foo::Plugin::AnError::an_error !!';
}
=cut

1;

__END__
