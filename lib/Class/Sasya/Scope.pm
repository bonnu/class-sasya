package Class::Sasya::Scope;

use strict;
use warnings;
use Carp ();

sub scope {
    my ($id, $scope, %options) = @_;
    return unless $id;
    bless { id => $id }, __PACKAGE__ . "::$scope";
}

sub id { $_[0]->{id} }

sub is_scope {
    my $id = shift;
    return unless $id;
    my $ref = ref $id || return;
    return if $ref =~ /^(ARRAY|CODE|GLOB|HASH|REF|Regexp|SCALAR)$/;
    return $id->isa(__PACKAGE__);
}

package Class::Sasya::Scope::eval;

use strict;
use warnings;
push our @ISA, qw/Class::Sasya::Scope/;

1;

__END__
