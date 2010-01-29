use strict;
use warnings;
use Test::More;
use HTTP::Request;
use Plack::Test;
use Plack::Request;

my $app = sub {
    my $req = Plack::Request->new(shift);

    is $req->cookies->{undef}, undef;
    is $req->cookies->{Foo}, 'Bar';
    is $req->cookies->{Bar}, 'Baz';
    is $req->cookies->{XXX}, 'Foo Bar';
    is $req->cookies->{YYY}, 0;

    $req->new_response(200)->finalize;
};

test_psgi $app, sub {
    my $cb = shift;
    my $req = HTTP::Request->new(GET => "/");
    $req->header(Cookie => 'Foo=Bar; Bar=Baz; XXX=Foo%20Bar; YYY=0; YYY=3');
    $cb->($req);
};

$app = sub {
    my $req = Plack::Request->new(shift);
    is_deeply $req->cookies, {};
    $req->new_response(200)->finalize;
};

test_psgi $app, sub {
    my $cb = shift;
    $cb->(HTTP::Request->new(GET => "/"));
};

done_testing;
