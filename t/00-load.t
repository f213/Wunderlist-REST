#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Wunderlist::REST' ) || print "Bail out!\n";
}

diag( "Testing Wunderlist::REST $Wunderlist::REST::VERSION, Perl $], $^X" );
