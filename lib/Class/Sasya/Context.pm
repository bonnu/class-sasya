package Class::Sasya::Context;

use Mouse;

has current => (
    is         => 'rw',
    isa        => 'Class::Sasya::Hook',
);

has goto => (
    is         => 'rw',
    isa        => 'Str',
    default    => '',
);

has errors => (
    metaclass  => 'Collection::Array',
    is         => 'rw',
    isa        => 'ArrayRef',
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
