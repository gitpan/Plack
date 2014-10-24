use strict;
use warnings;
use Test::More;
use Test::Requires qw( Path::Class );
use Plack::Middleware::Static;
use Plack::Builder;
use Plack::Util;
use HTTP::Request::Common;
use HTTP::Response;
use Cwd;
use Path::Class;
use Plack::Test;

my $base = cwd;
chdir "t";

my $handler = builder {
    enable "Plack::Middleware::Static",
        path => sub { s!^/share/!!}, root => "$base/share";
    enable "Plack::Middleware::Static",
        path => qr{\.(t|PL)$}i, root => '.';
    sub {
        [200, ['Content-Type' => 'text/plain', 'Content-Length' => 2], ['ok']]
    };
};

my %test = (
    client => sub {
        my $cb  = shift;

        {
            my $path = "00_compile.t";
            my $res = $cb->(GET "http://localhost/$path");
            is $res->content_type, 'application/x-troff', 'ok case';
            like $res->content, qr/use Test::More/;
            is file($path)->stat->size, length($res->content);
            is file($path)->slurp,$res->content;
        }

        {
            my $res = $cb->(GET "http://localhost/..%2f..%2f..%2fetc%2fpasswd.t");
            is $res->code, 403;
        }

        {
            my $res = $cb->(GET "http://localhost/..%2fMakefile.PL");
            is $res->code, 403, 'directory traversal';
        }

        {
            my $res = $cb->(GET "http://localhost/foo/not_found.t");
            is $res->code, 404, 'not found';
            is $res->content, 'not found';
        }

        {
            my $res = $cb->(GET "http://localhost/share/face.jpg");
            is $res->content_type, 'image/jpeg';
        }
    },
    app => $handler,
);

test_psgi %test;

done_testing;
