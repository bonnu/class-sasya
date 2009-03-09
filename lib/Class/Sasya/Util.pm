package Class::Sasya::Util;

use strict;
use warnings;
use base qw/Exporter/;
use Carp ();
use Module::Find ();

our @EXPORT_OK = qw/
    apply_all_plugin_hooks
    make_class_accessor
    make_class_only_accessor
    resolve_plugin_list
/;

# This method is not suitable for the style of Mouse.
# When "MouseX::ClassAttribute" is released in the future, that will be used.
sub make_class_accessor {
    my ($class, $field, $data) = @_;
    my $meta = $class->meta;
    my $sub = sub {
        my $ref = ref $_[0];
        if ($ref) {
            return $_[0]->{$field} = $_[1] if @_ > 1;
            return $_[0]->{$field} if exists $_[0]->{$field};
        }
        my $want_meta = $_[0]->meta;
        if (@_ > 1 && $class ne $want_meta->name) {
            return make_class_accessor($want_meta, $field)->(@_);
        }
        $data = $_[1] if @_ > 1;
        return $data;
    };
    if ($meta->isa('Mouse::Meta::Class')) {
        $meta->add_method($field => $sub);
    }
    else {
        # for plug-in
        no strict 'refs';
        no warnings 'redefine';
        *{$class . "::$field"} = $sub;
    }
    $sub;
}

sub make_class_only_accessor {
    my ($class, $field, $data) = @_;
    my $meta = $class->meta;
    my $sub  = sub {
        my $ref = ref $_[0];
        my $want_class = $_[0]->meta->name;
        if (@_ > 1 && $class ne $want_class) {
            return make_class_only_accessor($want_class, $field)->(@_);
        }
        if (@_ > 1 && ! ref $_[0]) {
            $data = $_[1];
        };
        return $data;
    };
    if ($meta->isa('Mouse::Meta::Class')) {
        $meta->add_method($field => $sub);
    }
    else {
        # for plug-in
        no strict 'refs';
        no warnings 'redefine';
        *{$class . "::$field"} = $sub;
    }
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

sub apply_all_plugin_hooks {
    my ($class, @plugins) = @_;
    for my $plugin (@plugins) {
        my $list = $plugin->meta->{hook_point} || next;
        for my $key (keys %{ $list }) {
            $class->add_hook($key, $_) for @{ $list->{$key} };
        }
    }
}

1;

__END__
