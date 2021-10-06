#!/usr/bin/perl -w
use strict "vars";
use lib qw(. /usr/lib/cgi-bin/ksplatform);
#use Digest::MD5 qw(md5_hex);
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
$response->{skus}=$ksplatformshared::dbh->selectall_arrayref("SELECT sku, number, accountbound FROM `Inventory` WHERE userId = ?", {Slice =>{}}, $ksplatformshared::player->{userId});



ksplatformshared::end($response);
