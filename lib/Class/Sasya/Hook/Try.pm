package Class::Sasya::Hook::Try;

use strict;
use warnings;
use base qw/Class::Sasya::Hook/;

sub traverse {
    my ($self, $context, $func) = @_;
    $context->add_path($self);
    my $depth = $context->depth;
    eval {
        $func->($self);
        map { $_->traverse($context, $func) } @{ $self->{_children} };
    };
    if ($@) {
        $context->add_error($@);
    }
    $context->cut_paths($depth);
}

1;

__END__
