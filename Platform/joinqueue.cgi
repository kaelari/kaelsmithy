#!/usr/bin/perl -w
use strict "vars";
use lib qw(. /usr/lib/cgi-bin/ksplatform);

use CGI qw(param);
$ksplatformshared::dbh=ksdbplatform::connectdb();
my $response = {};
ksplatformshared::init();

my $eventid=param("eventid");
my $deckid=param("deckid");
my $eventdata;
my $eventbasedata;

if ($eventid){
	$eventdata= $ksplatformshared::dbh->selectrow_hashref("SELECT * from `Playerevents` WHERE `rowid` = ?", undef, ($eventid));
	$eventbasedata=$ksplatformshared::dbh->selectrow_hashref("SELECT * from `events` where `EventId` = ?", undef, ($eventdata->{eventid}));
	if ($eventdata->{Status} ne "Entered"){
		$response->{status}="failed";
		$response->{reason}="Already queued or haven't finished drafting or some other issue. $eventdata->{Status}";
		ksplatformshared::end($response);
		exit;
	}
	$ksplatformshared::dbh->do("UPDATE `Playerevents` SET `status` = ? WHERE `rowid` = ?", undef, ("Queued", $eventid));
	$ksplatformshared::dbh->do("INSERT INTO `queue`(`playerid`,`queuekey`, `deckid`,`eventid`)VALUES(?,?,?,?)", undef, ( $ksplatformshared::player->{userId}, $eventbasedata->{queuekey}, $eventdata->{DeckId}, $eventid ));

}elsif ($deckid) {
	my $alreadyin = $ksplatformshared::dbh->selectrow_hashref("SELECT * from `queue` WHERE `queuekey` = ? and `playerid` = ?", undef, ("constructed", $ksplatformshared::player->{userId}));
	if ($alreadyin) {
		$response->{status}="failed";
		$response->{reason}="Already in Queue";
		ksplatformshared::end($response);
		exit;
	}
	my $deckinfo= $ksplatformshared::dbh->selectrow_hashref("SELECT * from `Decks` WHERE `deckid` = ? AND `ownerid` = ?", undef , ($deckid, $ksplatformshared::player->{userId}));
	if ($deckinfo->{formats}=~/standard/i){
		$ksplatformshared::dbh->do("INSERT INTO `queue`(`playerid`,`queuekey`, `deckid`,`eventid`)VALUES(?,?,?,?)", undef, ( $ksplatformshared::player->{userId}, "constructed", $deckid, 0));
	}else {
		$response->{status}="failed";
		$response->{reason}="Deck Not Legal";
		ksplatformshared::end($response);
		exit;
	}

}else {
	$response->{status}="failed";
	$response->{reason}="no event or deck";
	ksplatformshared::end($response);
	exit;
}



ksplatformshared::end($response);
