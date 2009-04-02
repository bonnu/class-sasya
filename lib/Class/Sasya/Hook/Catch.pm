package Class::Sasya::Hook::Catch;

use strict;
use warnings;
use base qw/Class::Sasya::Hook/;

sub traverse {
    my ($self, $context, $func) = @_;
    if ($context->has_error) {
        $context->current($self);
        $func->($self);
        return 0 if $context->goto;
        map {
            return 0 unless $_->traverse($context, $func)
        } @{ $self->{_children} };
    }
    return 1;
}

1;

__END__
