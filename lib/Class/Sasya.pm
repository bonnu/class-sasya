package Class::Sasya;

use strict;
use warnings;
use base qw/Class::Sasya::Class/;
use Mouse::Util qw/apply_all_roles get_linear_isa/;

use Class::Sasya::Hook;
use Class::Sasya::Util;

our $VERSION = '0.01';

our @EXPORT = qw/
    hook
    hooks
    plugins
    traversal_handler
/;

sub hook {
    my $class = caller;
    Class::Sasya::Hook::hook(@_);
}

sub hooks {
    my $class = caller;
    $class->_root->append_hooks({ level => 1 }, @_);
}

sub plugins {
    my $class = caller;
    apply_all_roles(
        $class,
        Class::Sasya::Util::resolve_plugin_list($class, @_),
    );
} 

sub traversal_handler (&) {
    my $class = caller;
    $class->_traversal_handler(@_);
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
