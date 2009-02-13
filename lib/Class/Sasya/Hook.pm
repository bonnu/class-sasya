package Class::Sasya::Hook;

use strict;
use warnings;
use base qw/Tree::Simple/;
use Carp ();
use Tree::Simple qw/use_weak_refs/;

use Class::Sasya::Callback;

sub hook {
    my ($id, $type, %options) = @_;
    my $class = __PACKAGE__ . (defined $type ? "::$type" : q//);
    return $class->new($id, undef, %options);
}

sub new {
    my ($class, $id, $parent, %options) = @_;
    if ($parent) {
        $parent->is_unique_on_fraternity($id)
            || Carp::croak "is not unique on fraternity : $id";
    }
    unless ($id) {
        $parent && Carp::croak 'id is necessary for the child.';
        $id = '/';
    }
    my $self = $class->SUPER::new({}, $parent);
    $self->setUID($id);
    $self->initialize(%options) if $self->can('initialize');
    return $self;
}

sub callback {
    return $_[0]->{callback} ||= Class::Sasya::Callback->new;
}

sub is_unique_on_fraternity {
    my ($self, $id) = @_;
    return unless defined $id && length $id;
    map { return if $_->getUID eq $id } ($self->getAllChildren);
    return 1;
}

sub _is_hook {
    my $id = shift || return;
    my $ref = ref $id || return;
    return if $ref =~ /^(ARRAY|CODE|GLOB|HASH|REF|Regexp|SCALAR)$/;
    return $id->isa(__PACKAGE__);
}

sub append_hooks {
    my ($self, @hooks) = @_;
    my $class = ref $self;
    while (my $id = shift @hooks) {
        my $hook;
        if (_is_hook($id)) {
            $self->addChild($hook = $id);
        }
        else {
            $hook = $class->new($id, $self);
        }
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

sub traverse {
    my ($self, $func) = @_;
    for my $child (@{ $self->{_children} }) {
        $func->($child);
        $child->traverse($func);
    }
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
