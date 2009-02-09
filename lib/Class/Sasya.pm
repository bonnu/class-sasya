package Class::Sasya;

use strict;
use warnings;
use base qw/Class::Sasya::Class/;
use Scalar::Util ();

our $VERSION = '0.01';

use Class::Sasya::Plugins;
use Class::Sasya::Hook;

__PACKAGE__->make_class_accessor(_plugins => Class::Sasya::Plugins->new);
__PACKAGE__->make_class_accessor(root     => Class::Sasya::Hook->new);

sub import {
    my $class  = shift;
    my $caller = caller;
    if ($class eq __PACKAGE__) {
        if ($caller ne 'main' && ! $caller->isa(__PACKAGE__)) {
            {
                no strict 'refs';
                push @{$caller . '::ISA'}, __PACKAGE__;
            }
            map { $class->export_to($caller, $_) } qw/
                accessors class_accessor class_accessors hooks plugins
            /;
        }
    }
}

sub accessors (@) {
    my $class = caller;
    $class->make_accessors(@_);
}

sub class_accessors (@) {
    my $class = caller;
    $class->make_class_accessors(@_);
}

sub class_accessor (@) {
    my $class = caller;
    $class->make_class_accessor(@_);
}

sub hooks (@) {
    my $class = caller;
    $class->root->append_hooks(@_);
}

# dirty
sub plugins (@) {
    my $class = caller;
    my @loaded = $class->_plugins->load(load_class => $class, @_);
    for my $plugin (@loaded) {
        $plugin->mixin_to($class) if $plugin->can('mixin_to');
        my @hooks = Class::Sasya::Plugin::hooks($plugin);
        while (my ($name, $sub) = splice @hooks, 0, 2) {
            $class->add_hook($name, $sub);
        }
    }
}

sub bootstrap {
    my ($class, @args) = @_;
    my $self = Scalar::Util::blessed $class ? $class : $class->new;
    $self->root->traverse(sub {
# undetermined
        my $node = shift;
        $node->invoke($self, @args);
    });
}

sub find_hook {
    my $class = shift;
    return $class->root->find_by_path(@_);
}

sub add_hook {
    my ($class, $name, $callback) = @_;
    if (my $hook = $class->find_hook($name)) {
        $hook->register($callback);
    }
}

1;

__END__

=encoding utf8

=head1 NAME

Class::Sasya -

=head1 SYNOPSIS

  use Class::Sasya;

=head1 DESCRIPTION

"Sasya" is one of the chocolate confectioneries that represent Japan.
It piles a chocolate as thin as the fiber like the layer,
is woven delicately, and is very delicious.

=head1 AUTHOR

Satoshi Ohkubo E<lt>s.ohkubo@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
