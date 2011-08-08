use inc::Module::Install;

name     'WWW-ViewText';
all_from 'lib/WWW/ViewText.pm';
author   q{Nikola Knezevic <laladelausanne@gmail.com>};
license  'perl';

requires 'JSON' => 0;
requires 'Class::Accessor::Fast' => 0;

build_requires 'Test::More';

auto_install;

WriteAll;

