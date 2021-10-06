#!/usr/bin/perl -w
use strict "vars";
use lib qw(. /usr/lib/cgi-bin/ksplatform);
use shared;
use CGI qw(param);
$ksplatformshared::dbh=ksdbplatform::connectdb();
my $response = {};
ksplatformshared::init();


$response->{games}=$ksplatformshared::dbh->selectall_arrayref("SELECT * from `Games` WHERE `ended` = 0 and (`player1` = ? or `player2` = ?)", {Slice=>{}}, ($ksplatformshared::player->{userId}, $ksplatformshared::player->{userId}));
foreach my $game (@{$response->{games}}){
	if ($game->{player1} == $ksplatformshared::player->{userId}){
		$game->{player1} = $ksplatformshared::player->{username};
		$game->{player2} = ksplatformshared::getusername($game->{player2});
		$game->{opponent} = $game->{player2};
		$game->{mydeck}=ksplatformshared::getdeckname($game->{deck1});
		delete ($game->{deck2});
		delete ($game->{deck1});
		
	}else{
		$game->{player2} = $ksplatformshared::player->{username};
		$game->{player1} = ksplatformshared::getusername($game->{player1});
		$game->{mydeck}=ksplatformshared::getdeckname($game->{deck2});
		$game->{opponent} = $game->{player1};
		delete ($game->{deck1});
		delete ($game->{deck2});
	}
	
	
}



ksplatformshared::end($response);
