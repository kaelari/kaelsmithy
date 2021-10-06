#!/usr/bin/perl -w
use strict "vars";
use lib qw(. /usr/lib/cgi-bin/ksplatform);
use Digest::MD5 qw(md5_hex);
use CGI qw(param);
$ksplatformshared::dbh=ksdbplatform::connectdb();
my $response = {};
ksplatformshared::init();

$response->{events}=$ksplatformshared::dbh->selectall_arrayref("SELECT * from `events` WHERE `Open` = 1 and `OpenDate` < NOW()", {Slice=>{}}, ());




ksplatformshared::end($response);
