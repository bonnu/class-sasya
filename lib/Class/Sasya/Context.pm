package Class::Sasya::Context;

use Mouse;
use MouseX::AttributeHelpers;
use Carp ();

has current => (
    is         => 'rw',
    isa        => 'Class::Sasya::Hook',
    trigger    => sub {
        my ($self, $hook) = @_;
        return unless $self->{skip};
        if ($hook eq $self->{next_target}) {
            $self->skip(0);
            $self->clear_goto;
        }
    },
);

has return => (
    is         => 'rw',
    isa        => 'Bool',
    default    => sub { 0 },
);

sub goto {
    my ($self, $path) = @_;
    $self->current
        || Carp::croak 'current position is not set.';
    my $hook = $self->current->find_by_path($path)
        || Carp::croak "specified path doesn't exist: $path";
    $self->next_target($hook);
    $self->skip(1);
}

has next_target => (
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
    is         => 'rw',
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
