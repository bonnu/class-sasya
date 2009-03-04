package Class::Sasya::Object;

use strict;
use warnings;
use base qw/Mouse::Object/;
use Scalar::Util ();
use Mouse::Meta::Class;

use Class::Sasya::Hook;
use Class::Sasya::Util;

Class::Sasya::Util::make_non_mop_class_accessor(
    Mouse::Meta::Class->initialize(__PACKAGE__),
    _root => Class::Sasya::Hook->new,
);

Class::Sasya::Util::make_non_mop_class_accessor(
    Mouse::Meta::Class->initialize(__PACKAGE__),
    _traversal_handler => sub {
        my ($self, @args) = @_;
        return sub { $_[0]->invoke($self, @args) };
    },
);

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

1;

__END__
