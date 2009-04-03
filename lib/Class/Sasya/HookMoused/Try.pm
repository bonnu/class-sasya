package Class::Sasya::HookMoused::Try;

use Mouse;
extends 'Class::Sasya::HookMoused';

sub traverse {
    my ($self, $context, $func) = @_;
    my $ret;
    eval {
        $ret = $self->SUPER::traverse($context, $func);
    };
    if ($@) {
        $context->add_error($@);
    }
    return defined $ret ? $ret : $self->CONTINUE;
}

1;

__END__
