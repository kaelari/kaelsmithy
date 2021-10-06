#!/usr/bin/perl -w
use strict "vars";
use lib qw(. /usr/lib/cgi-bin/ksplatform);
use Digest::MD5 qw(md5_hex);
use CGI qw(param);
$ksplatformshared::dbh=ksdbplatform::connectdb();
my $response = {};
ksplatformshared::init();

$response->{decks}=$ksplatformshared::dbh->selectall_arrayref("SELECT * from `Decks` WHERE `ownerid` = ? and eventid = 0", {Slice=>{}}, ($ksplatformshared::player->{userId}));




ksplatformshared::end($response);
