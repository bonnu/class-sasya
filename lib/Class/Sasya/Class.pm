package Class::Sasya::Class;

use strict;
use warnings;
use base qw/Mouse/;
use Mouse::Meta::Class;
use Mouse::Util qw/get_linear_isa/;

use Class::Sasya::Util;

our @EXPORT = qw/class_has/;

sub import {
    my $class  = shift;
    my $args   = defined $_[0] && ref $_[0] eq 'HASH' ? shift : {};
    my $caller = exists $args->{caller} ? $args->{caller} : caller;
    my $level  = exists $args->{level}  ? $args->{level}  : 1;
    return if $caller eq 'main';
    my $meta = Mouse::Meta::Class->initialize($caller);
    $meta->superclasses || $meta->superclasses('Class::Sasya::Object');
    {
        no strict 'refs';
        no warnings 'redefine';
        *{"$caller\::meta"} = sub { $meta };
    }
    $_->export_to_level($level) for @{ get_linear_isa($class) };
}

# When "MouseX::ClassAttribute" is released in the future, that will be used.
sub class_has {
    my $meta = Mouse::Meta::Class->initialize(caller);
    Class::Sasya::Util::make_non_mop_class_accessor($meta, @_);
}

sub unimport {
    my $class  = shift;
    my $caller = caller;
    my @isa    = @{ get_linear_isa($class) };
    {
        no strict 'refs';
        for my $class (@isa) {
            for my $keyword (@{"$class\::EXPORT"}) {
                delete ${"$caller\::"}{$keyword};
            }
        }
    }
    $caller->meta->make_immutable(inline_destructor => 1);
}

1;

__END__

=encoding utf-8

=head1 NAME

Class::Sasya::Class

=head1 SYNOPSIS

=cut
