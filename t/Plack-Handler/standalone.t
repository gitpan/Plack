use strict;
use warnings;
use Test::More;
use Test::Requires qw(HTTP::Parser::XS);

use FindBin;
use Plack;
use Plack::Test::Suite;

Plack::Test::Suite->run_server_tests('Standalone');
done_testing();

