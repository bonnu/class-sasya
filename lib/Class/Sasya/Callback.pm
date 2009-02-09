package Class::Sasya::Callback;

use strict;
use warnings;

sub new {
    my $class = shift;
    bless {
        order   => [],
        refs    => {},
        current => undef,
    }, $class;
}

sub add {
    my $self = shift;
    for my $ref (@_) {
        push @{ $self->{order} }, "$ref";
        $self->{refs}->{"$ref"} = $ref;
        $self->{current} = -1 unless defined $self->{current};
    }
}

sub iterate {
    my $self = shift;
    return unless defined $self->{current};
    if ($self->{current} == $#{ $self->{order} }) {
        $self->{current} = -1;
        return;
    }
    return $self->{refs}->{ $self->{order}->[ ++$self->{current} ] };
}

sub reset {
    my $self = shift;
    $self->{current} = 0 < @{ $self->{order} } ? -1 : undef;
}

1;

__END__

=encoding utf8

=head1 NAME

Class::Sasya::Callback -

=head1 SYNOPSIS

  use Class::Sasya::Callback;

=head1 DESCRIPTION

Class::Sasya::Callback is

=head1 AUTHOR

Satoshi Ohkubo E<lt>s.ohkubo@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
