package Class::Sasya::Context;

use Mouse;
use MouseX::AttributeHelpers;
use Carp ();

has return => (
    is         => 'rw',
    isa        => 'Bool',
    default    => sub { 0 },
);

has current => (
    is         => 'rw',
    isa        => 'Class::Sasya::Hook',
    trigger    => sub {
        my ($self, $hook) = @_;
        return unless $self->{skip};
        if ($hook eq $self->{_goto}) {
            $self->skip(0);
            $self->clear_goto;
        }
    },
);

sub goto {
    my ($self, $path) = @_;
    if ($path) {
        $self->current
            || Carp::croak 'current position is not set.';
        my $hook = $self->current->find_by_path($path)
            || Carp::croak "specified path doesn't exist: $path";
        $self->_goto($hook);
        $self->skip(1);
    }
    else {
        $self->_goto;
    }
}

has _goto => (
    is         => 'rw',
    isa        => 'Class::Sasya::Hook',
    clearer    => 'clear_goto',
);

has skip => (
    is         => 'rw',
    isa        => 'Bool',
    default    => sub { 0 },
);

has errors => (
    metaclass  => 'Collection::Array',
    is         => 'ro',
    isa        => 'ArrayRef',
    auto_deref => 1,
    default    => sub { [] },
    provides   => {
        count  => 'error_number',
        empty  => 'has_error',
        push   => 'add_error',
        shift  => 'shift_error',
        clear  => 'clear_errors',
    },
);

no Mouse;

__PACKAGE__->meta->make_immutable(inline_destructor => 1);

1;

__END__
