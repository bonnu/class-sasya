package Class::Sasya;

use Mouse;
extends 'Mouse';
# Class::Sasya always uses MouseX::AttributeHelpers.
use MouseX::AttributeHelpers;

our $VERSION = '0.01';

use Class::Sasya::Context;
use Class::Sasya::Hook;
use Class::Sasya::Util qw/
    apply_all_plugins
    apply_all_plugin_hooks
    make_class_accessor
    resolve_plugin_list
/;

our @EXPORT = qw/
    class_has
    hook
    hooks
    plugins
    traversal_handler
/;

sub import {
    strict->import;
    warnings->import;
    my $class = shift;
    my $caller = caller;
    return if $caller eq 'main';
    Mouse->import({ into_level => 1 });
    __PACKAGE__->export_to_level(1);
    export_for($caller);
    make_class_accessor(
        $caller,
        _root => Class::Sasya::Hook->new,
    );
    make_class_accessor(
        $caller,
        _traversal_handler => sub {
            my ($self, @args) = @_;
            return sub { $_[0]->invoke($self, @args) };
        },
    );
}

sub class_has {
    my $class = caller;
    make_class_accessor($class, @_);
}

sub hook {
    my $class = caller;
    Class::Sasya::Hook::hook(@_);
}

sub hooks {
    my $class = caller;
    $class->_root->append_hooks({ level => 1 }, @_);
}

sub plugins {
    my $class = caller;
    my @plugins = resolve_plugin_list($class, @_);
    apply_all_plugins($class, @plugins);
    apply_all_plugin_hooks($class, @plugins);
}

sub traversal_handler (&) {
    my $class = caller;
    $class->_traversal_handler(@_);
}

{
    sub bootstrap {
        my $class = shift;
        my $self  = Scalar::Util::blessed $class ? $class : $class->new;
        my $context = $self->context;
        my $handler = $self->_traversal_handler->($self, @_);
        $self->_root->initiate($context, $handler);
        $self;
    }
    
    sub find_hook {
        my $class = shift;
        return $class->_root->find_by_path(@_);
    }
    
    sub add_hook {
        my ($class, $name, $callback) = @_;
        if (my $hook = $class->find_hook($name)) {
            $hook->register($callback);
        }
    }

    sub context {
        my $self = shift;
        $self->{context} ||= Class::Sasya::Context->new;
    }
}

sub export_for {
    my $export_class = shift;
    my $meta = $export_class->meta;
    {
        no strict 'refs';
        delete ${"$export_class\::"}{'with'};
        for my $name (qw/bootstrap find_hook add_hook context/) {
            $meta->add_method($name, \&{$name});
        }
    }
}

sub unimport {
    my $class  = shift;
    my $caller = caller;
    {
        no strict 'refs';
        for my $key (@{__PACKAGE__ . '::EXPORT'}, @Mouse::EXPORT) {
            delete ${"$caller\::"}{$key};
        }
    }
}

1;

__END__

=encoding utf8

=head1 NAME

Class::Sasya - 

=head1 SYNOPSIS

 package Salute;
 use Class::Sasya; # automatically turns on strict and warnings (Mouse base)
 
 # The flow of event with hook is defined
 hooks
     'initialize'
     'main' => [qw/
         foo
         bar
         baz
     /],
     'finalize',
 ;
 
 # Modules that namespace corresponds to Salute::Plugin::* is loaded
 plugins
     namespace => [qw/ +Plugin::* /],
 ;

=head1 DESCRIPTION

=head2 What is "Sasya(or Sasha)" ?

"Sasya(or Sasha)" is one of the chocolate confectioneries that represent Japan.
It piles a chocolate as thin as the fiber like the layer,
is woven delicately, and is very delicious.

=head2 

=head1 KEYWORDS

=head2 hooks

=head2 hook

=head2 plugins

=head2 class_has

=head2 traersal_handler

=head1 

=head1 AUTHOR

Satoshi Ohkubo E<lt>s.ohkubo@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
