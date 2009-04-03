package Class::Sasya::HookMoused::Catch;

use Mouse;
extends 'Class::Sasya::HookMoused';

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
