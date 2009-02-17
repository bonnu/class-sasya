package Class::Sasya::Hook::EvalScope;

use strict;
use warnings;
use base qw/Class::Sasya::Hook/;

sub traverse {
    my ($self, $func) = @_;
    eval {
        $func->($self);
        map { $_->traverse($func) } @{ $self->{_children} };
    };
    if ($@) {
    }
}

1;

__END__
