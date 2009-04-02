package Class::Sasya::Hook::Try;

use strict;
use warnings;
use base qw/Class::Sasya::Hook/;

sub traverse {
    my ($self, $context, $func) = @_;
    eval {
        $context->current($self);
        $func->($self);
        return 0 if $context->goto;
        map {
            return 0 unless $_->traverse($context, $func)
        } @{ $self->{_children} };
    };
    if ($@) {
        $context->add_error($@);
    }
    return 1;
}

1;

__END__
