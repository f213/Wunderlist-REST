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
	plan tests => 9;
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


my $ret = $api->addList([title	=> 'WunderListRESTTestList']);
my $listId = $ret->{id};
ok(length $listId, 'list was created');

my @lists = $api->lists();
ok($#lists > 1, 'More than one list found');


foreach(@lists)
{
	pass("We've found created list") if $_->{id} eq $listId;
}

$ret = $api->addTask([
		list_id		=> $listId,
		title		=> 'WunderListTestTask',
]);
my $taskId = $ret->{id};

ok(length $taskId, 'task was created');

my @tasks = $api->tasks();

ok($#tasks > 1, 'More than one task found');

foreach(@tasks)
{
	pass("We've found created task") if $_->{id} eq $taskId;
}

$api->delTask($taskId);
$api->delList($listId);


