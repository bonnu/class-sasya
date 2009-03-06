package Class::Sasya::Plugin;

use strict;
use warnings;
use base qw/Mouse::Role/;

our @EXPORT = qw/
    hook_to
/;

sub import {
    strict->import;
    warnings->import;
    my $class = shift;
    my $caller = caller;
    return if $caller eq 'main';
    my $meta = Mouse::Meta::Role->initialize($caller);
    {
        no strict 'refs';
        no warnings 'redefine';
        *{$caller.'::meta'} = sub { $meta };
    }
    Mouse::Role->export_to_level(1, @_);
    Class::Sasya::Plugin->export_to_level(1, @_);
}

sub hook_to {
    my $class = caller;
}

1;

__END__

=encoding utf-8

=head1 NAME

Class::Sasya::Plugin

=cut
