package Class::Sasya;

use Mouse;
extends 'Mouse';
# Class::Sasya always uses MouseX::AttributeHelpers.
use MouseX::AttributeHelpers;

our $VERSION = '0.01';

use Class::Sasya::Hook;
use Class::Sasya::Util qw/
    apply_all_plugins
    apply_all_plugin_hooks
    apply_hooked_method
    make_class_accessor
    resolve_plugin_list
/;

our @EXPORT = qw/
    class_has
    hook
    hooks
    hook_to
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
    make_class_accessor($caller, _root => Class::Sasya::Hook->new);
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

sub hook_to {
    my $class = caller;
    my ($hook, $sub) = @_;
    my %sub_info;
    @sub_info{qw/
        sub
        package filename line subroutine hasargs wantarray evaltext
        is_require hints bitmask
    /} = ($sub, caller 0);
    apply_hooked_method($class, $hook, \%sub_info);
}

sub plugins {
    my $class = caller;
    my @plugins = resolve_plugin_list($class, @_);
    apply_all_plugins($class, @plugins);
    apply_all_plugin_hooks($class, @plugins);
}

sub traversal_handler (&) {
    my $class = caller;
    make_class_accessor($class, traversal_sub => shift);
}

{
    sub bootstrap {
        my $class = shift;
        my $self  = Scalar::Util::blessed $class ? $class : $class->new;
        $self->_root->initiate($self, @_);
        return $self;
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
}

sub export_for {
    my $export_class = shift;
    my $meta = $export_class->meta;
    $meta->add_attribute(
        context => (is => 'rw', isa => 'Class::Sasya::Context'),
    );
    {
        no strict 'refs';
        delete ${"$export_class\::"}{'with'};
        for my $name (qw/bootstrap find_hook add_hook/) {
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

Class::Sasya - Meta framework of stream driven

=head1 DESCRIPTION

=head2 What is "Sasya(or Sasha)" ?

"Sasya(or Sasha)" is one of the chocolate confectioneries that represent Japan.
It piles a chocolate as thin as the fiber like the layer,
is woven delicately, and is very delicious.

=head2 Conception

 blah blah blah

=head1 SYNOPSIS

 package Salute;
 use Class::Sasya; # automatically turns on strict and warnings (Mouse base, not Any::Moose)
 
 # The flow of event with hook is defined
 hooks
     'initialize'
     'dispatch' => [qw/
         before
         main
         after
     /],
     'finalize',
 ;
 
 # Modules that namespace corresponds to Salute::Plugin::* is loaded
 plugins
     namespace => [qw/ +Plugin::* /],
 ;

 hook_to '/dispatch/main' => sub {
     my ($self, @params) = @_;
     ...
 };

=head1 KEYWORDS

=head2 use Class::Sasya

=head2 hooks

=head2 hook

=head2 plugins

=head2 class_has

=head2 hook_to

=head2 traversal_handler

=head1 

=head1 AUTHOR

Satoshi Ohkubo E<lt>s.ohkubo@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
