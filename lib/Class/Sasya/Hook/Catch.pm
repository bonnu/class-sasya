package Class::Sasya::Hook::Catch;

use strict;
use warnings;
use base qw/Class::Sasya::Hook/;

sub traverse {
    my ($self, $context, $func) = @_;
    $context->current($self);
    my $ret = $self->CONTINUE;
    if ($context->has_error) {
        $ret = $self->SUPER::traverse($context, $func);
    }
    return $ret;
}

1;

__END__
