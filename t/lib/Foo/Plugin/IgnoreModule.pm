package Foo::Plugin::IgnoreModule;

use Class::Sasya::Plugin;

hook_to 'main/phase3' => 'noise';

__PACKAGE__->mk_accessors qw/ignore_accessor/;

sub noise {
    my $self = shift;
    $self->stash->{caption} .= '/* noise!! */';
}

1;

__END__
