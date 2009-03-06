package Foo::Plugin::Hello;

use Class::Sasya::Plugin;

hook_to 'main/phase1/sub1' => 'hello';

sub hello {
    my $self = shift;
    $self->stash->{caption} .= 'hello';
}

1;

__END__
