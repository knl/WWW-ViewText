#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'WWW::ViewText' ) || print "Bail out!
";
}

diag( "Testing WWW::ViewText $WWW::ViewText::VERSION, Perl $], $^X" );
