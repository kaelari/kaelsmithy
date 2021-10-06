#!/usr/bin/perl -w
package empty;
use lib qw(. /usr/lib/cgi-bin/ksplatform);

BEGIN {
	
	use strict;
	use CGI qw(param);	
	$ksplatformshared::dbh=ksdbplatform::connectdb();
	
}
my $response = {};

ksplatformshared::init();
if (!ksplatformshared::loggedin){
	$response->{status} = "Failed";
	$response->{message} = "Not Logged in";
	ksplatformshared::end($response);
}

my $deckid=param("deckid");
my $deckname = param("deckname");
my $deck = param("deck");

if (!$deck) {
	exit;
}
if (!$deckname) {
	my $foo=$ksplatformshared::dbh->selectrow_hashref("SELECT count(*) as total from `Decks` WHERE `ownerid` = ?", undef,  ($ksplatformshared::player->{userId}));
	$deckname="unnamed deck($foo->{total})";
}
my @cards = split(/, ?/, $deck);
my @formats;
if (checkstandard(\@cards)){
	push (@formats, "Standard");
}

$formatstring=join(", ", @formats);

my $foo=$ksplatformshared::dbh->selectrow_hashref("Select * from `Decks` where `ownerid` = ? and `deckname` = ? and `eventid` = 0 and `deckid` <> ?", undef, ($ksplatformshared::player->{userId}, $deckname, $deckid));
	my $count=0;
	my $decknamebase=$deckname;
	while ($foo) {
		$count+=1;
		$deckname=$decknamebase."($count)";
		$foo=$ksplatformshared::dbh->selectrow_hashref("Select * from `Decks` where `ownerid` = ? and `deckname` = ? and `eventid` = 0 and `deckid` <> ?", undef, ($ksplatformshared::player->{userId}, $deckname, $deckid));		
	}



if ($deckid <=0){ 
	#not overwrite, this is a new deck. will check if we already have a deck with this name;
	
	
	$ksplatformshared::dbh->do("INSERT INTO `Decks`(`ownerid`, `deckname`, `cards`, `formats`) VALUES(?,?,?, ?)", undef, ($ksplatformshared::player->{userId}, $deckname, $deck, $formatstring));
}else {
	
	
	
	
	$ksplatformshared::dbh->do("UPDATE `Decks` SET `deckname` = ?, `cards` = ?, `formats` = ? WHERE `deckid` = ? and `ownerid` = ? and `eventid` = 0", undef, ($deckname, $deck, $formatstring, $deckid, $ksplatformshared::player->{userId}) );
}




ksplatformshared::end($response);


sub checkstandard {
	my $cards = shift;
	if (scalar @{$cards} != 30){
		return 0;
	}
	my %cards;
	foreach my $card (@{$cards}){
		$cards{$card}+=1;
	}
	 foreach my $card (keys %cards){
		if ($cards{$card}>3){
			return 0
		}
	 }
	 return 1;
}

