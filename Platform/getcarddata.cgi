#!/usr/bin/perl -w
use strict "vars";
use lib qw(. /usr/lib/cgi-bin/ksplatform);
use shared;
use CGI qw(param);
$ksplatformshared::dbh=ksdbplatform::connectdb();
my $response = {};
ksplatformshared::init();
$response->{result}=$ksplatformshared::dbh->selectall_arrayref("SELECT * FROM `KS_cards`.`carddata` ORDER BY `cardid`", {Slice =>{}}, ());




ksplatformshared::end($response);
