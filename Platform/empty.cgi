#!/usr/bin/perl -w
use strict "vars";
use lib qw(. /usr/lib/cgi-bin/platform);
use shared;
use CGI qw(param);
$platformshared::dbh=dbplatform::connectdb();
my $response = {};
platformshared::init();



platformshared::end($response);
