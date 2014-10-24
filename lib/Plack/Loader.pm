package Plack::Loader;
use strict;
use Carp ();
use Plack::Util;
use Try::Tiny;

sub new {
    my $class = shift;
    bless {}, $class;
}

sub watch {
    # do nothing. Override in subclass
}

sub auto {
    my($class, @args) = @_;

    my $server = $class->guess
        or Carp::croak("Couldn't auto-guess server serverementation. Set it with PLACK_SERVER");

    $class->load($server, @args);
}

sub load {
    my($class, $server, @args) = @_;

    my($server_class, $error);
    for my $prefix (qw( Plack::Handler Plack::Server )) {
        try {
            $server_class = Plack::Util::load_class($server, $prefix);
        } catch {
            $error ||= $_;
        };
        last if $server_class;
    }

    if ($server_class) {
        $server_class->new(@args);
    } else {
        die $error;
    }
}

sub guess {
    my $class = shift;

    return $ENV{PLACK_SERVER} if $ENV{PLACK_SERVER};

    if ($ENV{PHP_FCGI_CHILDREN} || $ENV{FCGI_ROLE} || $ENV{FCGI_SOCKET_PATH}) {
        return "FCGI";
    } elsif ($ENV{GATEWAY_INTERFACE}) {
        return "CGI";
    } elsif (exists $INC{"AnyEvent.pm"}) {
        return "AnyEvent";
    } elsif (exists $INC{"Coro.pm"}) {
        return "Coro";
    } elsif (exists $INC{"POE.pm"}) {
        return "POE";
    } elsif (exists $INC{"Danga/Socket.pm"}) {
        return "Danga::Socket";
    } else {
        return "Standalone";
    }
}

sub run {
    my($self, $server, $builder) = @_;
    $server->run($builder->());
}

1;

__END__

=head1 NAME

Plack::Loader - (auto)load Plack Servers

=head1 SYNOPSIS

  # auto-select server backends based on env vars
  use Plack::Loader;
  Plack::Loader->auto(%args)->run($app);

  # specify the implementation with a name
  Plack::Loader->load('Standalone::Prefork', %args)->run($app);

=head1 DESCRIPTION

Plack::Loader is a factory class to load one of Plack::Handler subclasses based on the environment.

=head1 AUTOLOADING

C<< Plack::Loader->auto(%args) >> will autoload the most correct
server implementation by guessing from environment variables and Perl INC
hashes.

=over 4

=item PLACK_SERVER

  env PLACK_SERVER=AnyEvent ...

Plack users can specify the specific implementation they want to load
using the C<PLACK_SERVER> environment variable.

=item PHP_FCGI_CHILDREN, GATEWAY_INTERFACE

If there's one of FastCGI or CGI specific environment variables set,
use the corresponding server implementation.

=item %INC

If one of L<AnyEvent>, L<Coro>, L<POE> or L<Danga::Socket> is loaded,
the relevant implementation will be loaded.

=back

=cut


