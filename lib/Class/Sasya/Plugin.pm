package Class::Sasya::Plugin;

use strict;
use warnings;
use base qw/Mouse::Role/;

our $VERSION = '0.01';

use Class::Sasya::Util qw/
    make_class_accessor
    resolve_plugin_list
/;

our @EXPORT = qw/
    class_has
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
        *{$caller . '::meta'} = sub { $meta };
    }
    Mouse::Role->export_to_level(1, @_);
    Class::Sasya::Plugin->export_to_level(1, @_);
}

sub class_has {
    my $class = caller;
    make_class_accessor($class, @_);
}

sub hook_to {
    my ($hook, $sub) = @_;
    my $meta = Mouse::Meta::Role->initialize(caller);
    # Ad-hoc
    my $list = $meta->{hook_point} ||= {};
    push @{ $list->{$hook} ||= [] }, { class => $meta->name, sub => $sub };
}

sub unimport {
    my $class  = shift;
    my $caller = caller;
    {
        no strict 'refs';
        for my $key (@{__PACKAGE__ . '::EXPORT'}, @Mouse::Role::EXPORT) {
            delete ${"$caller\::"}{$key};
        }
    }
}

1;

__END__

=encoding utf-8

=head1 NAME

Class::Sasya::Plugin

=cut
