#!/usr/bin/perl -w
use strict "vars";
use lib qw(. /usr/lib/cgi-bin/ksplatform);
use CGI qw(param);
$ksplatformshared::dbh=ksdbplatform::connectdb();
my $response = {};
ksplatformshared::init();

my $eventid = param("event");
my $eventdata= $ksplatformshared::dbh->selectrow_hashref("SELECT * from `Playerevents` where `playerid` = ? and `eventid` = ? and `finished` =0", undef, ($ksplatformshared::player->{userId}, $eventid));
unless ($eventdata){
    $response->{status}="failed";
    $response->{message}="Not in event";
    end($response);

}

my $baseeventdata = $ksplatformshared::dbh->selectrow_hashref("SELECT * from `events` WHERE `eventid` = ?", undef, ($eventid));
$ksplatformshared::dbh->do("UPDATE `Playerevents` SET `finished` = 1 WHERE `rowid` = ?", undef, ($eventdata->{rowid}));

ksplatformshared::grantprizes($baseeventdata->{$eventdata->{wins}."win"}, $ksplatformshared::player->{UserId});


ksplatformshared::end($response);
