package Class::Sasya::Hook::Catch;

use strict;
use warnings;
use base qw/Class::Sasya::Hook/;

sub traverse {
    my ($self, $context, $func) = @_;
    if ($context->has_error) {
        $context->add_path($self);
        $func->($self);
        map { $_->traverse($context, $func) } @{ $self->{_children} };
        $context->pop_path;
    }
}

1;

__END__
