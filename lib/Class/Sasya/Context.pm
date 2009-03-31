package Class::Sasya::Context;

use Mouse;

has paths => (
    metaclass  => 'Collection::Array',
    is         => 'rw',
    isa        => 'ArrayRef',
    default    => sub { [] },
    provides   => {
        empty  => 'has_paths',
        push   => 'add_path',
        pop    => 'pop_path',
        clear  => 'clear_paths',
    },
);

sub depth     { scalar @{ $_[0]->{paths} } -1 }
sub current   { $_[0]->{paths}[-1] }
sub cut_paths { splice @{ $_[0]->{paths} }, $_[1] }

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

has goto => (
    is         => 'rw',
    isa        => 'Str',
    default    => '',
);

no Mouse;

__PACKAGE__->meta->make_immutable(inline_destructor => 1);

1;

__END__
