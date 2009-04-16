#!/usr/bin/env perl
use strict;
use warnings;
use Test::More 'no_plan';
use FindBin;
use lib "$FindBin::Bin/lib";

use Foo;

my $foo = Foo->new;

isa_ok  +$foo, 'Mouse::Object';

can_ok  +$foo, 'name';

is      $foo->name, 'Boofy', '$foo->name is "Boofy"';

can_ok  +$foo, 'message';

is      $foo->message, 'foo bar baz', '$foo->message is "foo bar baz"';

ok      !$foo->context, '$foo->context has not been defined yet';

$foo->bootstrap;

is      $foo->stash->{caption}, 'hello world!', '$foo->stash->{caption} is "hello world!"';

ok      $foo->context->has_error, '$foo->context has an error';
