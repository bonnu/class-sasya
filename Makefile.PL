use inc::Module::Install;

perl_version_from 'lib/Class/Sasya.pm';

name 'Class-Sasya';

all_from 'lib/Class/Sasya.pm';

my %requires = (
    'Mouse'                    => '0.39',
    'MouseX::AttributeHelpers' => '0.04',
    'Storable'                 => '2.18',
    'Tree::Simple'             => '1.18',
    'UNIVERSAL::require'       => '0.11',
    'Devel::InnerPackage'      => '0.3',
    'Module::Find'             => '0.06',
);

while (my ($key, $val) = each %requires) {
    requires $key => $val;
}

build_requires 'Test::More';
auto_include;
WriteAll;
