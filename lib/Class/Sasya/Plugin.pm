package Class::Sasya::Plugin;

use strict;
use warnings;
use base qw/Class::Sasya::Class/;
use Carp ();
use Scalar::Util ();

my $PLUGIN = {};

sub import {
    my $class = shift;
    if ($class eq __PACKAGE__ || $class->isa(__PACKAGE__)) {
        my $caller = caller 0;
        if (! $caller->isa("$class\::_Plugged") && $caller ne 'main') {
            {
                no strict 'refs';
                push @{"$caller\::ISA"}, "$class\::_Plugged";
            }
            $caller->add_method(hook_to => $class->can('hook_to'));
            $caller->add_method(option  => $class->can('option'));
            _initial_setting($caller);
        }
    }
}

sub hooks {
    my $plugin = shift;
    my $hooks;
    if (exists $PLUGIN->{$plugin}) {
        $hooks = $PLUGIN->{$plugin}->{hooks};
    }
    wantarray ? @{ $hooks || [] } : $hooks;
}

sub _initial_setting {
    my $plugin = shift;
    unless (exists $PLUGIN->{$plugin}) {
        $PLUGIN->{$plugin} = {};
        $PLUGIN->{$plugin}->{hooks} = [];
    }
}

sub is_plugin {
    my ($class, $plugin) = @_;
    $plugin->isa("$class\::_Plugged");
}

sub hook_to (@) {
    my $class = caller 0;
    my $hooks = hooks($class);
    while (my ($phase, $callback) = splice @_, 0, 2) {
        push @{ $hooks }, $phase, $callback;
    }
}

#
# >>> This function is making for trial purposes <<<
#
sub option ($;@) {
    my $class = caller 0;
    my ($attr, $type) = @_;
    $class->can($attr) && Carp::croak "$attr has already been defined";
    my $code;
    $code = $type if defined $type && ref $type eq 'CODE';
    unless ($code) {
        my $eval = (! defined $type || length $type <= 0) ? 'shift' :
                   $type eq 'SCALAR' ? 'shift'  :
                   $type eq 'ARRAY'  ? '[ @_ ]' :
                   $type eq 'HASH'   ? '{ @_ }' :
                   $type eq 'CODE'   ? 'shift'  :
                   $type eq 'REF'    ? 'ref $_[0] ? $_[0] : \$_[0]' :
                   Carp::croak "type is an argument not effective: $type";
        $code = eval "sub {
            my \$proto = shift;
            if (Scalar::Util::blessed \$proto) {
                return \$proto->_$attr;
            }
            elsif (\@_ <= 0) {
                return \$proto->_$attr;
            }
            my \$args = $eval;
            \$proto->add_method(_$attr => sub { \$args });
        }";
    }
    $class->add_method($attr => $code);
}

package Class::Sasya::Plugin::_Plugged;

use strict;
use warnings;
use base qw/Class::Sasya::Class/;

1;

__END__

=encoding utf-8

=head1 NAME

Class::Sasya::Plugin

=cut
