package Class::Sasya::Plugin;

use Mouse;
extends qw/Mouse::Role/;
use Carp qw/confess/;

our $VERSION = '0.01';

use Class::Sasya::Util qw/make_class_accessor/;

our @EXPORT = qw/class_has hook_to/;

Mouse::Exporter->setup_import_methods(as_is => [ @Mouse::Role::EXPORT, @EXPORT ]);

after 'import' => sub {
    my $class  = shift;
    my $caller = caller;
    return if $caller eq 'main';
    export_for($caller);
};

after 'with' => sub {
    my $class = caller;
    my $meta  = Mouse::Meta::Role->initialize($class);
    my $role  = shift;
    confess "Mouse::Role only supports 'with' on individual roles at a time" if @_;
    push @{ $class->sasya->{with_plugins} ||= [] }, $role;
};

around 'requires' => sub {
    my $orig  = shift;
    my $class = caller;
    my $meta  = Mouse::Meta::Role->initialize($class);
    $meta->throw_error("Must specify at least one method") unless @_;
    push @{ $class->sasya->{required_methods} ||= [] }, @_;
};

sub class_has {
    my $class = caller;
    make_class_accessor($class, @_);
}

sub hook_to {
    my ($hook, $sub) = @_;
    my $class = caller;
    my $sasya = $class->sasya;
    my $list  = $sasya->{hook_point} ||= {};
    my %sub_info;
    @sub_info{qw/
        sub
        package filename line subroutine hasargs wantarray evaltext is_require hints bitmask
    /} = ($sub, caller 0);
    push @{ $list->{$hook} ||= [] }, \%sub_info;
}

sub export_for {
    my $export_class = shift;
    my $meta = $export_class->meta;
    $meta->add_method($_, \&{$_}) for qw/sasya/;
}

{
    sub sasya {
        shift->meta->{+__PACKAGE__} ||= {};
    }
}

1;

__END__

=encoding utf-8

=head1 NAME

Class::Sasya::Plugin

=cut
