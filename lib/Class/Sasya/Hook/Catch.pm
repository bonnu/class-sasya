package Class::Sasya::Hook::Catch;

use strict;
use warnings;
use base qw/Class::Sasya::Hook/;

sub traverse {
    my ($self, $context, $func) = @_;
    my $ret;
    if ($context->has_error) {
        $ret = $self->SUPER::traverse($context, $func);
    }
    return $ret;
}

1;

__END__
