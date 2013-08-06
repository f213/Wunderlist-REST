package Wunderlist::REST;

use 5.006;
use strict;
use warnings;
use Badger::Class
	base		=> 'Badger::Base',
	config		=> [
		'login!',
		'password!',
		'timeout=5',
		'url=https://api.wunderlist.com',
	],
	mutators	=> 'ua uri',
;
use LWP::UserAgent;
use Rose::URI;
use JSON::XS qw /decode_json/;


=head1 NAME

Wunderlist::REST - Perl module for dealing with L<Wunderlist|https://www.wunderlist.com> api.

=head1 VERSION

Version 0.01


=head1 SYNOPSIS

This module utilizes Wunderlist API. Api is undocumented officialy, but it was reverse engineered by bsmt. The documentation can be found L<here|https://wunderpy.readthedocs.org/en/latest/index.html>. You should read that before working with this module.

Currently this module does not support even full CRUD, because i need only create and delete.


	use Wunderlist::REST;
	my $api = Wunderlist::REST->new(
    		login		=> 'myLogin',
		password	=> 'myPassword',
	);

	my $me = $api->me();
	say $me->{email};

	my $list = $api->addList(
		[
			title	=> 'TestList',
		]
	);

	my $task = $api->addTask(
		[
			title	=> 'TestTask',
			list_id	=> $list->{id},
		]
	);

	my @tasks = $api->tasks();
	my @lists = $api->lists();

	$api->delTask($task->{id});
	$api->delList($list->{id});
    ...


=cut

our $VERSION = '0.01';


=head1 SUBROUTINES/METHODS

=cut

sub init
{
	(my $self, my $config) = @_;
	
	$self->{config} = $self->configure($config);

	$self->ua(new LWP::UserAgent);
	$self->ua->timeout($self->{config}{timeout});

	$self->uri(Rose::URI->new($self->{config}{url}));

	$self->login();

	$self;
}


sub login
{
	my $self = shift;

	my $uri = $self->uri->clone;
	$uri->path('/login');
	
	my $response = $self->ua->post($uri->as_string,
		[
			email		=> $self->{config}{login},
			password	=> $self->{config}{password},
		],
	);
	if($response->is_error and $response->code != 404) # 404 Not Found is returned when auth credentials are bad
	{
		$self->error('Login HTTP error: ' . $response->status_line);
	}
	my $data = decode_json($response->content);
	if(exists $data->{errors})
	{
		$self->error('Login error: ' . $data->{errors}{message});
	}
	$self->{authToken} = $data->{token};
	return 1;
}

=head2 $api->me()

Get wunderlist information about the logged in account. L<https://wunderpy.readthedocs.org/en/latest/wunderlist_api/account/me.html>

=cut
sub me
{
	my $self = shift;

	$self->call('get', '/me');
}

=head2 $api->lists()

Get a list of all wunderlist lists. L<https://wunderpy.readthedocs.org/en/latest/wunderlist_api/lists/lists.html>.

=cut
sub lists
{
	my $self = shift;

	return @{$self->call('get', '/me/lists')};
}

=head2 $api->addList()

Create a new list, The only parameter Title is needed.

	$api->addList([title	=> 'testList']);
=cut
sub addList
{
	my $self = shift;

	return $self->call('post', '/me/lists', @_);
}

=head2 $api->delList()

Delete an existing list.

	$api->delList($listId);
=cut
sub delList
{
	my $self = shift;
	my $listId = shift;

	return $self->call('delete', "/$listId");
}

=head2 $api->tasks();

Get a list of all wunderlist tasks. L<https://wunderpy.readthedocs.org/en/latest/wunderlist_api/tasks/tasks.html>

=cut
sub tasks
{
	my $self = shift;
	
	return @{$self->call('get', '/me/tasks')};
}

=head2 $api->addTask()

Create a new list, The only parameter Title is needed.

	$api->addList(
		[
			title	=> 'testTask',
			listId	=> $listId,
		]
	);
=cut
sub addTask
{
	my $self = shift;
	
	return $self->call('post', '/me/tasks', @_);
}

=head2 $api->delTask()

Delete an existing task.

	$api->delList($listId);
=cut
sub delTask
{
	my $self = shift;
	my $taskId = shift;
	return $self->call('delete', "/$taskId");
}

sub call
{
	my $self = shift;
	my $what = shift;
	my $location = shift;

	my $uri = $self->uri->clone;
	$uri->path($location);
	
	my $response;
	if(@_)
	{
		$response = $self->ua->$what(
			$uri->as_string,
			$self->_authData(),
			Content	=> @_,
		);
	}
	else
	{
		$response = $self->ua->$what(
			$uri->as_string,
			$self->_authData(),
		);
	}

	if($response->is_error)
	{
		$self->error($response->status_line);
	}
	return decode_json($response->content);
}

sub _authData
{
	my $self = shift;

	return Authorization	=> 'Bearer ' . $self->{authToken};
}


=head1 AUTHOR

Fedor Borshev, C<< <fedor9 at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-wunderlist-rest at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Wunderlist-REST>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Wunderlist::REST


You can also look for information at:

=over 4

=item * Github

L<https://github.com/f213/Wunderlist-REST>

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Wunderlist-REST>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Wunderlist-REST>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Wunderlist-REST>

=item * Search CPAN

L<http://search.cpan.org/dist/Wunderlist-REST/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2013 Fedor Borshev.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of Wunderlist::REST
