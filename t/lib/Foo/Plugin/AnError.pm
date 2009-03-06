package Foo::Plugin::AnError;

use Class::Sasya::Plugin;

hook_to 'main/phase2' => 'an_error';

sub an_error {
    die 'died on Foo::Plugin::AnError::an_error !!';
}

1;

__END__
