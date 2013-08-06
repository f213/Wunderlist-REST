# NAME

Wunderlist::REST - Perl module for dealing with [Wunderlist](https://www.wunderlist.com) api.

# VERSION

Version 0.01



# SYNOPSIS

This module utilizes Wunderlist API. Api is undocumented officialy, but it was reverse engineered by bsmt. The documentation can be found [here](https://wunderpy.readthedocs.org/en/latest/index.html). You should read that before working with this module.

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



# SUBROUTINES/METHODS

## $api->me()

Get wunderlist information about the logged in account. [https://wunderpy.readthedocs.org/en/latest/wunderlist\_api/account/me.html](https://wunderpy.readthedocs.org/en/latest/wunderlist\_api/account/me.html)

## $api->lists()

Get a list of all wunderlist lists. [https://wunderpy.readthedocs.org/en/latest/wunderlist\_api/lists/lists.html](https://wunderpy.readthedocs.org/en/latest/wunderlist\_api/lists/lists.html).

## $api->addList()

Create a new list, The only parameter Title is needed.

	$api->addList([title	=> 'testList']);
=cut
sub addList
{
	my $self = shift;

	return $self->call('post', '/me/lists', @_);
}

## $api->delList()

Delete an existing list.

	$api->delList($listId);
=cut
sub delList
{
	my $self = shift;
	my $listId = shift;

	return $self->call('delete', "/$listId");
}

## $api->tasks();

Get a list of all wunderlist tasks. [https://wunderpy.readthedocs.org/en/latest/wunderlist\_api/tasks/tasks.html](https://wunderpy.readthedocs.org/en/latest/wunderlist\_api/tasks/tasks.html)

## $api->addTask()

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

## $api->delTask()

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

sub \_authData
{
	my $self = shift;

	return Authorization	=> 'Bearer ' . $self->{authToken};
}



# AUTHOR

Fedor Borshev, `<fedor9 at gmail.com>`

# BUGS

Please report any bugs or feature requests to `bug-wunderlist-rest at rt.cpan.org`, or through
the web interface at [http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Wunderlist-REST](http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Wunderlist-REST).  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.







# SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Wunderlist::REST



You can also look for information at:

- Github

    [https://github.com/f213/Wunderlist-REST](https://github.com/f213/Wunderlist-REST)

- RT: CPAN's request tracker (report bugs here)

    [http://rt.cpan.org/NoAuth/Bugs.html?Dist=Wunderlist-REST](http://rt.cpan.org/NoAuth/Bugs.html?Dist=Wunderlist-REST)

- AnnoCPAN: Annotated CPAN documentation

    [http://annocpan.org/dist/Wunderlist-REST](http://annocpan.org/dist/Wunderlist-REST)

- CPAN Ratings

    [http://cpanratings.perl.org/d/Wunderlist-REST](http://cpanratings.perl.org/d/Wunderlist-REST)

- Search CPAN

    [http://search.cpan.org/dist/Wunderlist-REST/](http://search.cpan.org/dist/Wunderlist-REST/)



# ACKNOWLEDGEMENTS



# LICENSE AND COPYRIGHT

Copyright 2013 Fedor Borshev.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

[http://www.perlfoundation.org/artistic\_license\_2\_0](http://www.perlfoundation.org/artistic\_license\_2\_0)

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


