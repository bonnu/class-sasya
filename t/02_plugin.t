#!/usr/bin/env perl
use strict;
use warnings;
use Test::More 'no_plan';
use FindBin;
use lib "$FindBin::Bin/lib";

{
    package CaseA;
    use Class::Sasya;

    plugins namespace => [qw/ TestPlugin::Hello /];
}

my $case_a = CaseA->new;

can_ok  +$case_a, 'hello';

{
    package CaseB;
    use Class::Sasya;

    eval { plugins namespace => [qw/ TestPlugin::World /] };

    main::like
        $@,
        qr/\A'TestPlugin::World' requires the method 'hello' to be implemented by 'CaseB'/;
}

{
    package CaseC;
    use Class::Sasya;

    plugins namespace => [qw/ TestPlugin::Hello TestPlugin::World /];
}

my $case_c = CaseC->new;

can_ok  +$case_c, 'hello';
can_ok  +$case_c, 'world';

is      $case_c->hello, 'Hello!';
is      $case_c->world, 'World!';

is      $case_c->say_hello_world, 'Hello world!';


