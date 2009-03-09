package Class::Sasya;

use Mouse;
use base qw/Exporter/;
use Mouse::Util qw/apply_all_roles get_linear_isa/;

our $VERSION = '0.01';

use Class::Sasya::Hook;
use Class::Sasya::Util qw/
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
    my $meta = $caller->meta;
    {
        no strict 'refs';
        delete ${"$caller\::"}{'with'};
        $meta->add_method($_, \&{$_}) for qw/bootstrap find_hook add_hook/;
    }
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
    apply_all_roles($class, @plugins);
    apply_all_plugin_hooks($class, @plugins);
}

sub traversal_handler (&) {
    my $class = caller;
    $class->_traversal_handler(@_);
}

{
    sub bootstrap {
        my $class = shift;
        my $self    = Scalar::Util::blessed $class ? $class : $class->new;
        my $handler = $self->_traversal_handler->($self, @_);
        $self->_root->traverse($handler);
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

sub unimport {
    my $class  = shift;
    my $caller = caller;
    my @isa    = @{ get_linear_isa($class) };
    {
        no strict 'refs';
        for my $class (@isa) {
            for my $keyword (@{"$class\::EXPORT"}) {
                delete ${"$caller\::"}{$keyword};
            }
        }
    }
    $caller->meta->make_immutable(inline_destructor => 1);
}

1;

__END__

=encoding utf8

=head1 NAME

Class::Sasya -

=head1 SYNOPSIS

 use Class::Sasya;

=head1 DESCRIPTION

"Sasya" is one of the chocolate confectioneries that represent Japan.
It piles a chocolate as thin as the fiber like the layer,
is woven delicately, and is very delicious.

=head1 AUTHOR

Satoshi Ohkubo E<lt>s.ohkubo@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
