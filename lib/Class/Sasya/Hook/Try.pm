package Class::Sasya::Hook::Try;

use strict;
use warnings;
use base qw/Class::Sasya::Hook/;

sub traverse {
    my ($self, $context, $func) = @_;
    my $ret;
    eval {
        $ret = $self->SUPER::traverse($context, $func);
    };
    if ($@) {
        $context->add_error($@);
    }
    return defined $ret ? $ret : Class::Sasya::Hook::CONTINUE;
}

1;

__END__
