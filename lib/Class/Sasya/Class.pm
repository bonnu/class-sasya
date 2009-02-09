package Class::Sasya::Class;

use strict;
use warnings;
use Array::Diff;
use Carp ();
use Class::Inspector;
use Sub::Install;

my @METHODS;

sub new {
    my ($proto, $fields) = @_;
    my ($class) = ref $proto || $proto;
    $fields = {} unless defined $fields;
    bless { %$fields }, $class;
}

sub make_accessors {
    my $class = shift;
    map { $class->make_accessor($_) } @_;
}

sub make_accessor {
    my ($class, $field) = @_;
    $class->add_method($field => sub {
        return $_[0]->{$field} if @_ == 1;
        return $_[0]->{$field} = $_[1] if @_ == 2;
        return (shift)->{$field} = \@_;
    })
}

sub make_class_accessors {
    my $class = shift;
    map { $class->make_class_accessor($_) } @_;
}

sub make_class_accessor {
    my ($class, $field, $data) = @_;
    my $sub = sub {
        my $ref = ref $_[0];
        if ($ref) {
            return $_[0]->{$field} = $_[1] if @_ > 1;
            return $_[0]->{$field} if exists $_[0]->{$field};
        }
        my $wantclass = $ref || $_[0];
        if (@_ > 1 && $class ne $wantclass) {
            return $wantclass->make_class_accessor($field)->(@_);
        }
        $data = $_[1] if @_ > 1;
        return $data;
    };
    $class->add_method($field => $sub);
    $sub;
}

sub _mixin_from (@) {
    my $target = 1 < @_ ? shift : caller;
    my $class = shift;
    mixin_to($class, $target);
}

sub mixin_to {
    my ($class, $target) = @_;
    $target ||= caller 0;
    my $diff = Array::Diff->diff(\@METHODS, _methods($class));
    for my $name (@{ $diff->added }) {
        add_method($target, $name => $class->can($name));
    }
}

sub add_method {
    my ($class, $name, $sub) = @_;
    Sub::Install::reinstall_sub({
        code => ref $sub eq 'CODE' ? $sub : sub { $sub },
        into => $class,
        as   => $name,
    });
    if ($class eq __PACKAGE__) {
        warn "The method was added to the prototype: $name";
        @METHODS = @{ __PACKAGE__->_methods };
    }
}

sub export_to {
    my ($class, $to, $name) = @_;
    add_method($to, $name, $class->can($name));
}

sub _methods {
    my $class = shift;
    Class::Inspector->methods($class, @_);
}

{
    no warnings 'once';
    *mixin = \&_mixin_from;
}

@METHODS = @{ __PACKAGE__->_methods };

1;

__END__

=encoding utf-8

=head1 NAME

Class::Sasya::Class

=head1 SYNOPSIS

=cut
