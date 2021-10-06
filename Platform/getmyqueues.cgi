#!/usr/bin/perl -w
use lib qw(. /usr/lib/cgi-bin/ksplatform);
use Data::Dumper qw (Dumper);
	
	use strict;
	use CGI qw(param);	
	$ksplatformshared::dbh=ksdbplatform::connectdb();
	

my $response = {};
ksplatformshared::init();

$response->{result}=$ksplatformshared::dbh->selectall_arrayref("SELECT * from `queue` where `playerid` = ?", {Slice=>{}}, ($ksplatformshared::player->{userId}));
foreach my $data (@{$response->{result}}){
	my $deckname = $ksplatformshared::dbh->selectrow_hashref("SELECT * from `Decks` WHERE `deckid` = ?", undef, ($data->{deckid}));
	$data->{deckname}=$deckname->{deckname};

}

ksplatformshared::end($response);
