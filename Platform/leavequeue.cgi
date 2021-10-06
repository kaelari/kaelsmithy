#!/usr/bin/perl -w
use strict "vars";
use lib qw(. /usr/lib/cgi-bin/ksplatform);

use CGI param;
$ksplatformshared::dbh=ksdbplatform::connectdb();
my $response = {};
ksplatformshared::init();

my $eventid=param("eventid");
my $queueid = param("queueid");
my $eventdata;
my $eventbasedata;
my $data = $ksplatformshared::dbh->selectrow_hashref("SELECT * from `queue` WHERE `playerid` = ? and `rowid` = ?", undef, ($ksplatformshared::player->{userId}, $queueid));
if (!$queueid){
	$response->{status}="failed";
	$response->{reason}="no queue id.";
	ksplatformshared::end($response);
	exit;
}


if ($data->{eventid}){
	$eventdata= $ksplatformshared::dbh->selectrow_hashref("SELECT * from `Playerevents` WHERE `rowid` = ?", undef, ($data->{eventid}));
#	$eventbasedata=$ksplatformshared::dbh->selectrow_hashref("SELECT * from `events` where `EventId` = ?", undef, ($eventdata->{eventid}));
	if ($eventdata->{Status} ne "Queued"){
		$response->{status}="failed";
		$response->{reason}="not queued or haven't finished drafting or some other issue. $eventdata->{Status}";
		ksplatformshared::end($response);
		exit;
	}
	$ksplatformshared::dbh->do("UPDATE `Playerevents` SET `status` = ? WHERE `rowid` = ?", undef, ("Entered", $data->{eventid}));
}else {
	
}

$ksplatformshared::dbh->do("Delete from `queue` where `rowid` = ? ", undef, ( $data->{rowid} ));


ksplatformshared::end($response);
