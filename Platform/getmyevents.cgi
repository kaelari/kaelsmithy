#!/usr/bin/perl -w
use strict "vars";
use lib qw(. /usr/lib/cgi-bin/ksplatform);
use shared;
use CGI qw(param);
$ksplatformshared::dbh=ksdbplatform::connectdb();
my $response = {};
ksplatformshared::init();
if (!$ksplatformshared::loggedin){
    $response->{status}="failed";
    $response->{message}="Not logged in";
    ksplatformshared::end($response);
}
$response->{result} = $ksplatformshared::dbh->selectall_arrayref("SELECT * from `Playerevents` WHERE `playerid` = ? and `finished` = 0", {Slice=>{}}, ($ksplatformshared::player->{userId}));





ksplatformshared::end($response);
