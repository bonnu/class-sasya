package Class::Sasya::Hook::EvalScope;

use strict;
use warnings;
use base qw/Class::Sasya::Hook/;

sub traverse {
    my ($self, $func) = @_;
    for my $child (@{ $self->{_children} }) {
        $func->($child);
        $child->traverse($func);
    }
}

1;

__END__
