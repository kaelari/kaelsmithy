#!/usr/bin/perl -w
use strict "vars";
use lib qw(. /usr/lib/cgi-bin/ksplatform);
use CGI qw(param);
$ksplatformshared::dbh=ksdbplatform::connectdb();
my $response = {};
#init();

my $game=param("game");
my $password=param("password");
my $winner = param("winner");
warn "game has ended! $game, $password, $winner";
if ($password ne "ajdkhfaksjfhakdsaflkjhas"){
	warn ("No access to end game!");
	$response->{status}="failed";
	$response->{reason}="no access";
	ksplatformshared::end($response);
	exit;
}
if (!$game){
	$response->{status}="failed";
	$response->{reason}="no game";
	ksplatformshared::end($response);
	exit;
}
if (!$winner){ 
	$response->{status}="failed";
	$response->{reason}="no winner";
	ksplatformshared::end($response);
	exit;
}


my $gamedata = $ksplatformshared::dbh->selectrow_hashref("SELECT * from `Games` where `gameId` = ?", undef, ($game));
unless ($gamedata) {
	warn "no gamedata";
	$response->{status}="failed";
	$response->{reason}="no game data";
	ksplatformshared::end($response);
	exit;
}
if ($gamedata->{ended}){
	warn "game ended";
	$response->{status}="failed";
	$response->{reason}="game ended";
	ksplatformshared::end($response);
	exit;
}
$ksplatformshared::dbh->do("UPDATE `Games` SET `ended` = 1 WHERE `gameId` = ?", undef, ($game) );
if ($gamedata->{eventId1}){
	if ($winner==1){
		$ksplatformshared::dbh->do("UPDATE `Playerevents` SET `wins` = `wins`+ 1 WHERE `rowid` = ? ", undef, ($gamedata->{eventId1}));
	}
	$ksplatformshared::dbh->do("UPDATE `Playerevents` SET `gamesplayed` = `gamesplayed`+ 1, `Status` = \"Entered\" WHERE `rowid` = ? ", undef, ($gamedata->{eventId1}));
	my $eventinfo = $ksplatformshared::dbh->selectrow_hashref("SELECT * FROM `Playerevents` WHERE `rowid` = ? ", undef, ($gamedata->{eventId1}));
	my $baseeventdata = $ksplatformshared::dbh->selectrow_hashref("SELECT * from `events` WHERE `eventid` = ?", undef, ($eventinfo->{eventid}));
	if ($eventinfo->{gamesplayed} >= $baseeventdata->{gamesneeded}){
		$ksplatformshared::dbh->do("UPDATE `Playerevents` SET `finished` = 1 WHERE `rowid` = ?", undef, ($eventinfo->{rowid}));
		ksplatformshared::grantprizes($baseeventdata->{$eventinfo->{wins}."win"}, $gamedata->{player1});
		grantachievement($gamedata->{player1}, 6);
		if ($eventinfo->{wins}>=4){
			grantachievement($gamedata->{player1}, 7);
		}
	}

}
if ($gamedata->{eventId2}){
	if ($winner==2){
		$ksplatformshared::dbh->do("UPDATE `Playerevents` SET `wins` = `wins`+ 1 WHERE `rowid` = ? ", undef, ($gamedata->{eventId2}));
	}
	$ksplatformshared::dbh->do("UPDATE `Playerevents` SET `gamesplayed` = `gamesplayed`+ 1, `Status` = \"Entered\" WHERE `rowid` = ? ", undef, ($gamedata->{eventId2}));
	my $eventinfo = $ksplatformshared::dbh->selectrow_hashref("SELECT * FROM `Playerevents` WHERE `rowid` = ? ", undef, ($gamedata->{eventId2}));
	my $baseeventdata = $ksplatformshared::dbh->selectrow_hashref("SELECT * from `events` WHERE `eventid` = ?", undef, ($eventinfo->{eventid}));
	if ($eventinfo->{gamesplayed} >= $baseeventdata->{gamesneeded}){
		$ksplatformshared::dbh->do("UPDATE `Playerevents` SET `finished` = 1 WHERE `rowid` = ?", undef, ($eventinfo->{rowid}));
		ksplatformshared::grantprizes($baseeventdata->{$eventinfo->{wins}."win"}, $gamedata->{player2});
		grantachievement($gamedata->{player2}, 6);
		if ($eventinfo->{wins}>=4){
			grantachievement($gamedata->{player2}, 7);
		}
	}

}
ksplatformshared::addachievement($gamedata->{player1}, 4, 1);
ksplatformshared::addachievement($gamedata->{player2}, 4, 1);
if ($winner == 1 ){ 
		ksplatformshared::sendmessage("Won game $game", $gamedata->{player1});
		ksplatformshared::sendmessage("Lost game $game", $gamedata->{player2});
		ksplatformshared::addachievement($gamedata->{player1}, 5, 1);
	}

if ($winner == 2 ){ 
		ksplatformshared::sendmessage("Won game $game", $gamedata->{player2});
		ksplatformshared::sendmessage("Lost game $game", $gamedata->{player1});
		ksplatformshared::addachievement($gamedata->{player2}, 5, 1);
	}


ksplatformshared::end($response);
