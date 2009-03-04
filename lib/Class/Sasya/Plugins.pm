package Class::Sasya::Plugins;

use strict;
use warnings;
use Carp ();
use Module::Find ();
use UNIVERSAL::require;

sub new {
    my $class = shift;
    bless { loaded => {} }, $class;
}

sub _regularize (\@$) {
    my ($classes, $class) = @_;
    for my $s (@{ $classes }) {
        $s =~ s/^\+/$class\::/;
        $s =~ s/\*$/.*/;
        $s =~ s/::*/::/g;
        $s = "^$s\$";
    }
}

sub load {
    my ($self, %options) = @_;
    my $load_class = $options{load_class}   || q{};
    my @namespace  = @{ $options{namespace} || [] };
    my @ignore     = @{ $options{ignore}    || [] };
    $load_class || Carp::croak 'load_class is not specified';
    @namespace  || Carp::croak 'namespace is not specified';
    my $allowed_char = '[+*:\w]';
    map {
        /^$allowed_char*$/ ||
            Carp::croak "reg-exp cannot be used to specify namespace : $_";
    } (@namespace, @ignore);
    _regularize @namespace, $load_class;
    _regularize @ignore,    $load_class;
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
    my @loaded;
    for my $module (@modules) {
        next if grep { $module =~ /$_/ } @ignore;
        $module->require or die $@;
        push @loaded, $module;
    }
    my $loaded  = $self->{loaded}->{$load_class} ||= [];
    push @{ $loaded }, @loaded;
    @loaded;
}

1;

__END__
