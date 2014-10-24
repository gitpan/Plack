package Plack::Server;
use strict;

1;

__END__

=head1 NAME

Plack::Server - Standard interface for Plack implementations

=head1 SYNOPSIS

  my $server = Plack::Server::XXX->new(%args);
  $server->run($app);

=head1 DESCRIPTION

Plack::Server is a base class of Plack PSGI implementations. Plack::Server
may inherit from this class, but as long as they implement the methods
defined as an Server unified interface, they do not need to inherit
Plack::Server.

=head1 METHODS

=over 4

=item new

  $server = Plack::Server::XXX->new(%args);

Creates a new implementation object. I<%args> can take arbitrary
parameters per implementations but common parameters are:

=over 8

=item port

Port number the server listens to.

=item address

Address the server listens to. Set to undef to listen any interface.

=back

=item run

  $server->run($app)

Starts the server process and when a request comes in, run the PSGI application passed in C<$app>.

=back

=head1 SEE ALSO

rackup

=cut

