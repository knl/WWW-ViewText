use inc::Module::Install;

name     'WebService-ViewText';
all_from 'lib/WebService/ViewText.pm';
author   q{Nikola Knezevic <laladelausanne@gmail.com>};
license  'perl';

requires 'JSON' => 0;
requires 'Class::Accessor::Fast' => 0;

build_requires 'Test::More';

auto_install;

WriteAll;

