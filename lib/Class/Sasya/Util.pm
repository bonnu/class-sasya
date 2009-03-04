package Class::Sasya::Util;

use strict;
use warnings;
use Carp ();
use Module::Find ();

# This method is not suitable for the style of Mouse.
# When "MouseX::ClassAttribute" is released in the future, that will be used.
sub make_non_mop_class_accessor {
    my ($class, $field, $data) = @_;
    my $sub = sub {
        my $ref = ref $_[0];
        if ($ref) {
            return $_[0]->{$field} = $_[1] if @_ > 1;
            return $_[0]->{$field} if exists $_[0]->{$field};
        }
        my $wantclass = $ref || $_[0];
        if (@_ > 1 && $class ne $wantclass) {
            return make_non_mop_class_accessor($wantclass, $field)->(@_);
        }
        $data = $_[1] if @_ > 1;
        return $data;
    };
    $class->add_method($field => $sub);
    $sub;
}

sub resolve_plugin_list {
    my ($class, %args) = @_;
    my @namespace  = @{ $args{namespace} || [] };
    my @ignore     = @{ $args{ignore}    || [] };
    $class      || Carp::croak 'class is not specified';
    @namespace  || Carp::croak 'namespace is not specified';
    my $allowed_char = '[+*:\w]';
    map {
        /^$allowed_char*$/ ||
            Carp::croak "reg-exp cannot be used to specify namespace : $_";
    } (@namespace, @ignore);
    _regularize_namespace($class, \@namespace);
    _regularize_namespace($class, \@ignore);
    my (@ns, @class);
    for my $re (@namespace) {
        if ($re =~ /^\^(.*)?(?=::\.\*\$$)/) {
            push @ns, $1;
        }
        else {
            (my $name = $re) =~ s/(^\^|\$$)//g;
            push @class, $name;
        }
    }
    my @modules = (@class, map { Module::Find::findallmod($_) } @ns);
    my @plugins;
    for my $module (@modules) {
        next if grep { $module =~ /$_/ } @ignore;
        push @plugins, $module;
    }
    @plugins;
}

sub _regularize_namespace {
    my ($class, $classes) = @_;
    for my $s (@{ $classes }) {
        $s =~ s/^\+/$class\::/;
        $s =~ s/\*$/.*/;
        $s =~ s/::*/::/g;
        $s = "^$s\$";
    }
}

1;

__END__
