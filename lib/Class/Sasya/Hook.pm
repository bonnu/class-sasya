package Class::Sasya::Hook;

use strict;
use warnings;
use base qw/Tree::Simple/;
use Carp ();
use Storable ();
use Tree::Simple qw/use_weak_refs/;
use UNIVERSAL::require;

use Class::Sasya::Callback;
use Class::Sasya::Context;

sub BREAK    () { 0 }
sub CONTINUE () { 1 }

sub hook {
    my ($id, $type, %args) = @_;
    my $class = __PACKAGE__;
    if ($type) {
        $class .= "::$type";
        $class->require or Carp::confess $@;
    }
    return $class->new($id, undef, %args);
}

sub new {
    my ($class, $id, $parent, %args) = @_;
    if ($parent) {
        $parent->is_unique_on_fraternity($id)
            || Carp::croak "is not unique on fraternity : $id";
    }
    unless ($id) {
        $parent && Carp::croak 'id is necessary for the child.';
        $id = '/';
    }
    my $self = $class->Tree::Simple::new({}, $parent);
    $self->setUID($id);
    if ($self->can('initialize')) {
        $self->initialize(%args);
    }
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
    my $id  = shift || return;
    my $ref = ref $id || return;
    return if $ref =~ /^(ARRAY|CODE|GLOB|HASH|REF|Regexp|SCALAR)$/;
    return $id->isa(__PACKAGE__);
}

sub append_hooks {
    my ($self, $args, @hooks) = @_;
    my $level = exists $args->{level} ? delete $args->{level} : 0;
    while (my $id = shift @hooks) {
        my $hook;
        if (_is_hook($id)) {
            $self->addChild($hook = $id);
        }
        else {
            $hook = $self->get_root->new($id, $self);
        }
        if (0 < @hooks && ref $hooks[0] eq 'ARRAY') {
            $hook->append_hooks(
                { %{ $args }, level => $level + 1 }, @{ shift @hooks },
            );
        }
    }
}

sub register {
    my $self = shift;
    $self->callback->add(@_);
}

sub invoke {
    my ($self, $obj, @args) = @_;
    my $callback = $self->{callback} || $self->callback;
    $callback->reset;
    while (my $sub = $callback->iterate) {
        my $ret = ref $sub ? $sub->($obj, @args) : $obj->$sub(@args);
        return 0 unless $ret;
    }
    return 1;
}

sub initiate {
    my ($self, $obj, @args) = @_;
    my $context = Class::Sasya::Context->new;
    $obj->context($context);
    my $default_cb    = sub { $_[0]->invoke($obj, @args) };
    my $callback_sub  = $obj->callback_sub->($obj, @args) || $default_cb;
    my $traversal_sub = $obj->traversal_sub->();
    do {
        last if $context->return;
        $self->traverse($context, $callback_sub, $traversal_sub);
    } while ($context->goto);
}

sub traverse {
    my ($self, $context, $func, $traversal_sub) = @_;
    if ($traversal_sub) {
        return $traversal_sub->($self, $context, $func, $traversal_sub);
    }
    $context->current($self);
    my $ret = 1;
    $ret = $func->($self) unless $context->skip;
    return BREAK if $context->return;
    if ($ret) {
        map {
            return BREAK unless $_->traverse($context, $func)
        } @{ $self->{_children} };
    }
    return CONTINUE;
}

sub initiate_scanning {
    my ($self, $obj, $creator, @args) = @_;
    my $context = Class::Sasya::Context->new;
    $obj->context($context);
    my ($before_cb, $after_cb);
    if (ref $creator eq 'HASH') {
        $before_cb = $creator->{before}->($obj, @args) if exists $creator->{before};
        $after_cb  = $creator->{after} ->($obj, @args) if exists $creator->{after};
    }
    else {
        $before_cb = $creator->($obj, @args); # or die
    }
    $self->_scanning($context, $before_cb, $after_cb);
}

sub _scanning {
    my ($node, $context, $before_cb, $after_cb) = @_;
    $context->current($node);
    $before_cb->($node);
    map {
        $_->_scanning($context, $before_cb, $after_cb);
    } @{ $node->{_children} };
    $after_cb->($node) if $after_cb;
}

sub get_path {
    my $self = shift;
    my $cur  = $self;
    my @path;
    until ($cur->isRoot) {
        unshift @path, $cur->{_uid};
        $cur = $cur->getParent;
    }
    return '/' . join '/', @path;
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

sub clone {
    my $self = shift;
    return Storable::dclone($self);
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
