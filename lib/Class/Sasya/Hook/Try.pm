package Class::Sasya::Hook::Try;

use strict;
use warnings;
use base qw/Class::Sasya::Hook/;

sub traverse {
    my ($self, $context, @args) = @_;
    my $ret;
    eval {
        $ret = $self->SUPER::traverse($context, @args);
    };
    if ($@) {
        $context->add_error($@);
    }
    return defined $ret ? $ret : $self->CONTINUE;
}

1;

__END__
