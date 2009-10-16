package Class::Sasya::Util;

use strict;
use warnings;
use base qw/Exporter/;
use Carp qw/croak/;
use Class::Inspector;
use Devel::InnerPackage ();
use Module::Find ();
use Mouse::Meta::Class;
use Mouse::Meta::Role;
use Mouse::Util ();
use Scalar::Util qw/blessed/;

our @EXPORT_OK = qw/
    make_class_accessor
/;

my @PLUGIN_OMIT_METHOD_NAMES = do {
    (
        @Mouse::Role::EXPORT,
        @Class::Sasya::Plugin::EXPORT,
        qw/meta sasya/,
    );
};

sub recollect_required_methods {
    my $applicant = Mouse::Meta::Class->initialize(shift);
    my @plugins   = @_;
    for my $plugin (@plugins) {
        next unless $plugin->can('sasya');
        if (my $required = $plugin->sasya->{required_methods}) {
            my $dummy    = Mouse::Meta::Role->create(undef);
            $dummy->add_required_methods(@{ $required });
            eval {
                $dummy->_check_required_methods($applicant, { _to => 'class' });
            };
            if ($@) {
                $@ =~ s/Mouse::Meta::Role::__ANON__::\d+/$plugin/;
                die $@;
            }
        }
    }
}

sub apply_all_plugin_hooks {
    my ($class, @plugins) = @_;
    for my $plugin (@plugins) {
        next unless $plugin->can('sasya');
        my $list = $plugin->sasya->{hook_point} || next;
        for my $hook (keys %{ $list }) {
            map { apply_hooked_method($class, $hook, $_) } @{ $list->{$hook} }
        }
    }
}

sub register_plugins_info {
    my ($class, @plugins) = @_;
    my $sasya  = $class->sasya;
    my $loaded = $sasya->{loaded_plugins} ||= [];
    for my $plugin (@plugins) {
        my $methods = Class::Inspector->methods($plugin);
        my @methods = grep {
            my $f = $_;
            ! grep { $_ eq $f } @PLUGIN_OMIT_METHOD_NAMES
        } @{ $methods };
        push @{ $loaded }, { class => $plugin, method => \@methods };
    }
}

sub apply_hooked_method {
    my ($class, $hook, $sub_info) = @_;
    my $meta = Mouse::Meta::Class->initialize($class);
    my $sub  = $sub_info->{'sub'};
    my $ref  = ref $sub;
    if ($ref && $ref eq 'CODE') {
        my $code = $sub;
        $sub = make_method_name($sub_info->{package} || $class, $hook);
        return if $class->can($sub);
        $meta->add_method($sub => $code);
    }
    elsif ($ref) {
        croak #XXX
    }
    $class->add_hook($hook => $sub);
}

sub make_method_name {
    my ($class_name, $hook) = @_;
    $class_name =~ s!::!-!g;
    "$hook:$class_name";
}

# This method is not suitable for the style of Mouse.
# When "MouseX::ClassAttribute" is released in the future, that will be used.
sub make_class_accessor {
    my ($class, $field, $data) = @_;
    my $meta = Mouse::Meta::Class->initialize($class);
    my $sub = sub {
        my $ref = ref $_[0];
        if ($ref) {
            return $_[0]->{$field} = $_[1] if @_ > 1;
            return $_[0]->{$field} if exists $_[0]->{$field};
        }
        my $want_meta = $_[0]->meta;
        if (1 < @_ && $class ne $want_meta->name) {
            return make_class_accessor($want_meta->name, $field)->(@_);
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

sub get_loaded_plugins {
    my $class = shift;
    my %loaded;
    for my $super (@{ Mouse::Util::get_linear_isa($class) }) {
        next unless $super->can('sasya');
        next unless exists $super->sasya->{loaded_plugins};
        for my $plugin (@{ $super->sasya->{loaded_plugins} }) {
            my $info = $loaded{$plugin->{class}} ||= {};
            if (my $at = $info->{at}) {
                $at = $info->{at} = [ $at ] unless ref $at;
                push @{ $at }, $super;
            }
            else {
                $info->{at} = $super;
            }
        }
    }
    wantarray ? keys %loaded : \%loaded;
}

sub resolve_plugin_list {
    my $class = shift;
    my (@namespace, @ignore);
    if (1 == scalar @_) {
        push @namespace,
            (ref $_[0] && ref $_[0] eq 'ARRAY') ? @{ $_[0] } : $_[0];
    }
    else {
        my %args = @_;
        @namespace = @{ $args{namespace} || [] };
        @ignore    = @{ $args{ignore}    || [] };
    }
    $class      || croak 'class is not specified';
    @namespace  || croak 'namespace is not specified';
    my $allowed_char = '[+*:\w]';
    map {
        /^$allowed_char*$/ ||
            croak "reg-exp cannot be used to specify namespace : $_";
    } (@namespace, @ignore);
    _regularize_namespace($class, \@namespace);
    _regularize_namespace($class, \@ignore);
    my (@ns, @class);
    for my $re (@namespace) {
        if ($re =~ /^\^(.*)?(?=::\.\*\$$)/) {
            push @ns, $1;
            push @class, Devel::InnerPackage::list_packages($1);
        }
        else {
            (my $name = $re) =~ s/(^\^|\$$)//g;
            push @class, $name;
        }
    }
    my @modules = (@class, map { Module::Find::findallmod($_) } @ns);
    my $loaded  = get_loaded_plugins($class);
    my @plugins;
    for my $module (@modules) {
        next if grep { $module =~ /^$_$/ } @ignore;
        next if exists $loaded->{$module};
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

sub resolve_plugin_at_with {
    my ($class, $plugin_list) = @_;
    my @at_with;
    my $loaded = $class->sasya->{loaded_plugins};
    for my $plugin (@{ $plugin_list }) {
        next unless $plugin->can('sasya');
        next unless exists $plugin->sasya->{with_plugins};
        for my $comate (@{ $plugin->sasya->{with_plugins} }) {
            push @at_with, $comate
                if grep { $comate ne $_->{class} } @{ $loaded };
        }
    }
    push @{ $plugin_list }, @at_with;
}

1;

__END__
