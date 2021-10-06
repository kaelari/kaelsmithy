#!/usr/bin/perl -w
use strict "vars";
use lib qw(. /usr/lib/cgi-bin/ksplatform);
use CGI qw(param);
$ksplatformshared::dbh=ksdbplatform::connectdb();
my $response = {};
ksplatformshared::init();
my $achievement=param("achievement");
my $progress = (param("progress") or 1);
my $result=$ksplatformshared::dbh->selectrow_hashref("SELECT * FROM `Achievements` WHERE `achievementid` = ?", undef, ($achievement));
if ($result->{trustclient}){
	
	ksplatformshared::addachievement($platformshared::player->{userId}, $achievement, $progress);
}


ksplatformshared::end($response);
