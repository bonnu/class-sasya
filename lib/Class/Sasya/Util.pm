package Class::Sasya::Util;

use strict;
use warnings;
use base qw/Exporter/;
use Carp qw/croak confess/;
use Devel::InnerPackage qw/list_packages/;
use Module::Find qw/findallmod/;
use Mouse::Meta::Class;

our @EXPORT_OK = qw/
    apply_all_plugins
    apply_all_plugin_hooks
    make_class_accessor
    resolve_plugin_list
/;

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
            push @class, list_packages($1);
        }
        else {
            (my $name = $re) =~ s/(^\^|\$$)//g;
            push @class, $name;
        }
    }
    my @modules = (@class, map { findallmod($_) } @ns);
    my @plugins;
    for my $module (@modules) {
        next if grep { $module =~ /^$_$/ } @ignore;
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

# The part of base was stolen from Mouse::Util::apply_all_roles.
sub apply_all_plugins {
    my $meta = Mouse::Meta::Class->initialize(shift);
    my @roles;
    # Basis of Data::OptList
    my $max = scalar(@_);
    for (my $i = 0; $i < $max ; $i++) {
        if ($i + 1 < $max && ref($_[$i + 1])) {
            push @roles, [ $_[$i++] => $_[$i] ];
        } else {
            push @roles, [ $_[$i] => {} ];
        }
    }
    require Mouse;
    foreach my $role_spec (@roles) {
        Mouse::load_class($role_spec->[0]);
    }
    ( $_->[0]->can('meta') && $_->[0]->meta->isa('Mouse::Meta::Role') )
        || croak("You can only consume roles, "
        . $_->[0]
        . " is not a Moose role")
        foreach @roles;
    # Following contexts were changed.
    combine_apply($meta, @roles);
}

# The part of base was stolen from Mouse::Meta::Role::combine_apply.
sub combine_apply {
    my($meta, @roles) = @_;
    my $classname = $meta->name;
#### Delaying this processing enables Role class to supplement 'requires' each other. 
#   if ($meta->isa('Mouse::Meta::Class')) {
#       for my $role_spec (@roles) {
#           my $self = $role_spec->[0]->meta;
#           for my $name (@{$self->{required_methods}}) {
#               next if $classname->can($name);
#               my $method_required = 0;
#               for my $role (@roles) {
#                   if ($self->name ne $role->[0] && $role->[0]->can($name)) {
#                       $method_required = 1;
#                   }
#               }
#               confess
#                   "'" . $self->name .
#                   "' requires the method '$name' to be implemented by '$classname'"
#                   unless $method_required;
#           }
#       }
#   }
    {
        no strict 'refs';
        for my $role_spec (@roles) {
            my $self = $role_spec->[0]->meta;
            my $selfname = $self->name;
            my %args = %{ $role_spec->[1] };
            for my $name ($self->get_method_list) {
                next if $name eq 'meta';

                if ($classname->can($name)) {
                    # XXX what's Moose's behavior?
                    #next;
                } else {
                    *{"${classname}::${name}"} = *{"${selfname}::${name}"};
                }
                if ($args{alias} && $args{alias}->{$name}) {
                    my $dstname = $args{alias}->{$name};
                    unless ($classname->can($dstname)) {
                        *{"${classname}::${dstname}"} = *{"${selfname}::${name}"};
                    }
                }
            }
        }
    }
    if ($meta->isa('Mouse::Meta::Class')) {
        # apply role to class
        for my $role_spec (@roles) {
            my $self = $role_spec->[0]->meta;
            for my $name ($self->get_attribute_list) {
                next if $meta->has_attribute($name);
                my $spec = $self->get_attribute($name);

                my $metaclass = 'Mouse::Meta::Attribute';
                if ( my $metaclass_name = $spec->{metaclass} ) {
                    my $new_class = Mouse::Util::resolve_metaclass_alias(
                        'Attribute',
                        $metaclass_name
                    );
                    if ( $metaclass ne $new_class ) {
                        $metaclass = $new_class;
                    }
                }
                $metaclass->create($meta, $name, %$spec);
            }
        }
    } else {
        # apply role to role
        # XXX Room for speed improvement
        for my $role_spec (@roles) {
            my $self = $role_spec->[0]->meta;
            for my $name ($self->get_attribute_list) {
                next if $meta->has_attribute($name);
                my $spec = $self->get_attribute($name);
                $meta->add_attribute($name, $spec);
            }
        }
    }
    # XXX Room for speed improvement in role to role
    for my $modifier_type (qw/before after around/) {
        my $add_method = "add_${modifier_type}_method_modifier";
        for my $role_spec (@roles) {
            my $self = $role_spec->[0]->meta;
            my $modified = $self->{"${modifier_type}_method_modifiers"};

            for my $method_name (keys %$modified) {
                for my $code (@{ $modified->{$method_name} }) {
                    $meta->$add_method($method_name => $code);
                }
            }
        }
    }
#### Delaying this processing enables Role class to supplement 'requires' each other. 
    if ($meta->isa('Mouse::Meta::Class')) {
        for my $role_spec (@roles) {
            my $self = $role_spec->[0]->meta;
            for my $name (@{$self->{required_methods}}) {
                next if $classname->can($name);
                my $method_required = 0;
                for my $role (@roles) {
                    if ($self->name ne $role->[0] && $role->[0]->can($name)) {
                        $method_required = 1;
                    }
                }
                confess
                    "'" . $self->name .
                    "' requires the method '$name' to be implemented by '$classname'"
                    unless $method_required;
            }
        }
    }
#### :(
    # append roles
    my %role_apply_cache;
    my @apply_roles;
    for my $role_spec (@roles) {
        my $self = $role_spec->[0]->meta;
        push @apply_roles, $self unless $role_apply_cache{$self}++;
        for my $role ($self->roles) {
            push @apply_roles, $role unless $role_apply_cache{$role}++;
        }
    }
}

sub apply_all_plugin_hooks {
    my ($class, @plugins) = @_;
    my $meta = Mouse::Meta::Class->initialize($class);
    my $loaded = $meta->{_loaded_plugins} ||= [];
    for my $plugin (@plugins) {
        push @{ $loaded }, $plugin;
        my $list = $plugin->meta->{hook_point} || next;
        for my $hook (keys %{ $list }) {
            for my $method_name (@{ $list->{$hook} }) {
                my $ref = ref $method_name;
                if ($ref && $ref eq 'CODE') {
                    my $code = $method_name;
                    $method_name = _make_method_name($plugin, $hook);
                    $meta->add_method($method_name => $code);
                }
                $class->add_hook($hook => $method_name);
            }
        }
    }
}

sub _make_method_name {
    my ($plugin_class, $hook_point) = @_;
    $plugin_class =~ s!::!_!g;
    $hook_point   =~ s!/!_!g;
    lc $hook_point . '__' . $plugin_class;
}

1;

__END__
