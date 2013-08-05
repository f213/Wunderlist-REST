use strict;
use warnings;
use utf8;
use Test::More;
use File::Slurp qw /read_file/;

our ($login, $password);

eval
{
	$login		= read_file('./t/real_auth_data/login');
	$password	= read_file('./t/real_auth_data/password');

	chomp $login;
	chomp $password;
};

if(not $login or not $password)
{
	plan skip_all	=> 'This tests need real auth data';
}
else
{
	plan tests => 4;
}

use Wunderlist::REST;

my $api;

eval
{
	$api = Wunderlist::REST->new(
		login		=> 'badLogin',
		password	=> 'badPassW0Rd',
	);
};

ok( (! defined $api or ! $api->isa('Wunderlist::REST')), 'Object init with bad auth');

$api = Wunderlist::REST->new(
	login		=> $login,
	password	=> $password,
);
isa_ok($api, 'Wunderlist::REST', 'Instance after login');

my $me = $api->me();

# if email is correctly fetched, it means that authorization works fine
is($me->{email}, $login, 'Fetch email');


my @lists = $api->lists();

ok($#lists > 1, 'More than one list found');

my $listId = $lists[int(rand($#lists-1))]->{id};
