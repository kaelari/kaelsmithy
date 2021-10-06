#!/usr/bin/perl -w
use strict;
import CGI qw(param);
use Data::Dumper;
use warnings FATAL => 'all';
$ksgameshared::dbh = ksdb::connectdb();
my $response = {};
ksgameshared::init();

unless ($ksgameshared::loggedin){
    $response->{"status"} = "Not Logged in";
    ksgameshared::end($response);
    exit;
}
my $game=param("game");
ksgameshared::loadgame($game);
our $weare=0;
our $opp=0;
if (!$ksgameshared::gamedata ){
	ksgameshared::logmessage("ERROR CAn't LOAD GAME");
	exit;
	
}


if (!$ksgameshared::player->{userId} ){
    warn "AHHH no userID!";
    exit;
    
}


if ($ksgameshared::gamedata->{players}{1}{playerid} != $ksgameshared::player->{userId}){
    #we are 2
    $weare=2;
    $opp=1;
}else {
    $weare=1;
    $opp=2;
}


foreach my $playerid (keys %{$ksgameshared::gamedata->{players}}){
    if ($ksgameshared::gamedata->{players}{$playerid}{playerid} == $ksgameshared::player->{userId}){

    }else {
        
        $ksgameshared::gamedata->{players}{$playerid}{hand} = int @{$ksgameshared::gamedata->{players}{$playerid}{hand}};
    }
    @{$ksgameshared::gamedata->{"deck$weare"}}=sort(@{$ksgameshared::gamedata->{deck1}});
    @{$ksgameshared::gamedata->{"deck$opp"}}=[];
}
ksgameshared::debuglog(Data::Dumper::Dumper($ksgameshared::gamedata->{forceplay}));
$response->{messages} = ksgameshared::sendnewmessages($game);
foreach my $object (keys %{$ksgameshared::gamedata->{objects} } ){
	if ($ksgameshared::gamedata->{forceplay}[0]){
		ksgameshared::debuglog("We have a forceplay");
		if ($ksgameshared::gamedata->{forceplay}[0]{revealtargets}){
			ksgameshared::debuglog("We have a revealtargets");
			my $found=0;
			foreach my  $showobject (@{$ksgameshared::gamedata->{forceplay}[0]{targets}[0]{raw}}) {
				if ($showobject == $object){
					$found=1;
					last;
				}
			}
			if ($found){
				ksgameshared::debuglog("We should see $object");
				next;
			}
		}
	}
	if (defined ($ksgameshared::gamedata->{objects}{$object}{zone} ) and $ksgameshared::gamedata->{objects}{$object}{zone} eq "play"){
		next;
	}
	if (defined ($ksgameshared::gamedata->{objects}{$object}{zone}) and  $ksgameshared::gamedata->{objects}{$object}{zone} eq "hand" and $ksgameshared::gamedata->{objects}{$object}{owner} == $weare){
		next;
	}
	if ($ksgameshared::gamedata->{objects}{$object}{owner} == $weare){
		next;
	}
	delete $ksgameshared::gamedata->{objects}{$object};
}

$response->{gamedata}=$ksgameshared::gamedata;
if ($response->{gamedata}{hidden}{$opp} ){
    delete($response->{gamedata}{hidden}{$opp});
}
ksgameshared::end($response);
