package Foo::Plugin::IgnoreModule;

use Mouse::Role;
=pod
use strict;
use warnings;
use Class::Sasya::Plugin;

hook_to 'main/phase3' => 'noise';

__PACKAGE__->mk_accessors qw/ignore_accessor/;

sub noise {
    my $self = shift;
    $self->stash->{caption} .= '/* noise!! */';
}
=cut

1;

__END__
