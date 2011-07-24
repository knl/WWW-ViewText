#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'WebService::ViewText' ) || print "Bail out!
";
}

diag( "Testing WebService::ViewText $WebService::ViewText::VERSION, Perl $], $^X" );
