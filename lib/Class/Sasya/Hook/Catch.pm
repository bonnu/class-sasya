package Class::Sasya::Hook::Catch;

use strict;
use warnings;
use base qw/Class::Sasya::Hook/;

sub traverse {
    my ($self, $func) = @_;
    $func->($self);
    map { $_->traverse($func) } @{ $self->{_children} };
}

1;

__END__
