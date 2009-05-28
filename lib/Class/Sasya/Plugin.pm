package Class::Sasya::Plugin;

use strict;
use warnings;
use base qw/Mouse::Role/;
use Carp qw/confess/;

our $VERSION = '0.01';

use Class::Sasya::Util qw/
    make_class_accessor
    resolve_plugin_list
    apply_hooked_method
/;

our @EXPORT = qw/
    class_has
    hook_to
    with
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
        *{$caller . '::meta'}  = sub { $meta };
        *{$caller . '::sasya'} = sub { shift->meta->{'Class::Sasya::Plugin'} ||= {} };
    }
    Mouse::Role->export_to_level(1, grep { $_ ne 'with' } @Mouse::Role::EXPORT);
    Class::Sasya::Plugin->export_to_level(1, @_);
}

sub class_has {
    my $class = caller;
    make_class_accessor($class, @_);
}

sub hook_to {
    my ($hook, $sub) = @_;
    my $sasya = caller->sasya;
    my $list  = $sasya->{hook_point} ||= {};
    my %sub_info;
    @sub_info{qw/
        sub
        package filename line subroutine hasargs wantarray evaltext
        is_require hints bitmask
    /} = ($sub, caller 0);
    push @{ $list->{$hook} ||= [] }, \%sub_info;
}

# The part of base was stolen from Mouse::Role::with(v0.22).
sub with {
    my $class = caller;
    my $meta  = Mouse::Meta::Role->initialize($class);
    my $role  = shift;
    my $args  = shift || {};
    confess "Mouse::Role only supports 'with' on individual roles at a time" if @_ || !ref $args;
    require Mouse;
    Mouse::load_class($role);
    $role->meta->apply($meta, %$args);
    _plugin_with($class, $role);
}

sub _plugin_with {
    my ($class, $role) = @_;
    my $with = $class->sasya->{with_plugins} ||= [];
    push @{ $with }, $role;
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
