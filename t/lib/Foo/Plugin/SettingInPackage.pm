package Foo::Plugin::SettingInPackage;

use Mouse::Role;
=pod
use strict;
use warnings;
use Class::Sasya::Plugin;

hook_to 'main/phase3/sub3' => 'footer';

option 'a' => 'SCALAR';

option 'b' => 'ARRAY';

option 'c' => 'HASH';

option 'd' => 'REF';

option 'e' => 'CODE';

option 'f' => sub { my ($class, %args) = @_; \%args };

option 'g';

sub footer {
    my $self = shift;
    $self->stash->{caption} .= ' ' . $self->a;
}
=cut

1;

__END__
