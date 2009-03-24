package Class::Sasya::Context;

use Mouse;

has errors => (
    is         => 'rw',
    isa        => 'ArrayRef',
    auto_deref => 1,
    default    => sub { [] },
);

no Mouse;

__PACKAGE__->meta->make_immutable(inline_destructor => 1);

sub add_error { push @{ shift->errors }, @_   }
sub has_error { 0 < scalar @{ shift->errors } }

1;

__END__
