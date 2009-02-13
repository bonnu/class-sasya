package Class::Sasya::Hook;

use strict;
use warnings;
use base qw/Tree::Simple/;
use Carp qw/croak/;
use Tree::Simple qw/use_weak_refs/;

use Class::Sasya::Callback;
use Class::Sasya::Scope;

sub new {
    my ($class, $id, $parent) = @_;
    my $scope;
    if (Class::Sasya::Scope::is_scope($id)) {
        $scope = $id;
        $id    = $scope->id;
    }
    if ($parent) {
        $parent->is_unique_on_fraternity($id)
            || croak "is not unique on fraternity : $id";
    }
    unless ($id) {
        $parent && croak 'id is necessary for the child.';
        $id = '/';
    }
    my $self = $class->SUPER::new({}, $parent);
    $self->setUID($id);
    $self->set_scope($scope);
    return $self;
}

sub callback {
    $_[0]->{callback} ||= Class::Sasya::Callback->new;
}

sub is_unique_on_fraternity {
    my ($self, $id) = @_;
    return unless defined $id && length $id;
    map { return if $_->getUID eq $id } ($self->getAllChildren);
    return 1;
}

sub append_hooks {
    my ($self, @hooks) = @_;
    my $class = ref $self;
    while (my $id = shift @hooks) {
        my $hook = $class->new($id, $self);
        if (0 < @hooks && ref $hooks[0] eq 'ARRAY') {
            $hook->append_hooks(@{ shift @hooks });
        }
    }
}

sub register {
    my $self = shift;
    $self->callback->add(@_);
}

sub invoke {
    my ($self, $root, @args) = @_;
    my $callback = $self->{callback} || $self->callback;
    while (my $sub = $callback->iterate) {
        my $ret = ref $sub ? $sub->($root, @args) : $root->$sub(@args);
        unless ($ret) {
            $callback->reset;
            last;
        }
    }
}

# This function is customizing of Tree::Simple::traverse.
sub traverse {
    my ($self, $func) = @_;
    for my $child (@{ $self->{_children} }) {
        $func->($child);
        $child->traverse($func);
    }
}

sub set_scope {
    my ($self, $scope) = @_;
    $self->{_scope} = $scope;
}

sub get_scope {
    $_[0]->{_scope};
}

sub get_path {
    my $self = shift;
    my $cur  = $self;
    my @path;
    until ($cur->isRoot) {
        unshift @path, $cur->getUID;
        $cur = $cur->getParent;
    }
    return join '/', q//, @path;
}

sub get_root {
    my $self = shift;
    return $self if $self->isRoot;
    return $self->getParent->get_root;
}

sub find_by_path {
    my $self = shift;
    my @path = @_ == 1 ? split m{(?:(?<=^/)|(?<!^)/)}, $_[0] : @_;
    my $cur  = $self;
    if (0 < @path && $path[0] eq '/') {
        shift @path;
        $cur = $self->get_root;
    }
    if (0 < @path) {
        my $id = shift @path;
        for my $child ($cur->getAllChildren) {
            return $child->find_by_path(@path) if $child->getUID eq $id;
        }
        undef $cur;
    }
    return $cur ? $cur : ();
}

1;

__END__

=encoding utf8

=head1 NAME

Class::Sasya::Hook -

=head1 SYNOPSIS

  use Class::Sasya::Hook;

=head1 DESCRIPTION

Class::Sasya::Hook is

=head1 AUTHOR

Satoshi Ohkubo E<lt>s.ohkubo@gmail.comE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
