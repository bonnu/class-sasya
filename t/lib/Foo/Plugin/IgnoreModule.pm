package Foo::Plugin::IgnoreModule;

use strict;
use warnings;
use Class::Sasya::Plugin;

hook_to phase3 => 'noise';

__PACKAGE__->mk_accessors qw/ignore_accessor/;

sub noise {
    my $self = shift;
    $self->stash->{caption} .= '/* noise!! */';
}

1;

__END__
