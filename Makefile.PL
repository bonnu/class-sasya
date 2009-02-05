use inc::Module::Install;
name 'Class-Sasya';
all_from 'lib/Class/Sasya.pm';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
