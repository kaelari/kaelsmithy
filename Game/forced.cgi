#!/usr/bin/perl -w
use strict;
use lib qw(. /usr/lib/cgi-bin/game);
use CGI qw(param);
use JSON;
my $response = {};
ksgameshared::init();
$ksgameshared::dbh=ksdb::connectdb();
unless ($ksgameshared::loggedin){
    ksgameshared::end();
    exit;
}
my $game=param("game");
$ksgameshared::game = $game;
ksgameshared::loadgame($ksgameshared::game);

if ($ksgameshared::gamedata->{ended} > 0){
    $response->{status} = "Failed";
    $response->{message} = "game has ended";
    ksgameshared::end($response);
    exit;
}

if (!$ksgameshared::gamedata->{forceplay}){
    $response->{Status}="failed";
    $response->{Message} = "No forced action needed";
    ksgameshared::end($response);
    exit;
}

our $weare=0;
our $opp =0;

if ($ksgameshared::gamedata->{players}{1}{playerid} != $ksgameshared::player->{userId}){
    #we are 2
    $weare=2;
    $opp=1;
}else {
    $weare=1;
    $opp=2;
}
if ($ksgameshared::gamedata->{turn} != $weare ){
    #it's not our turn!
    $response->{status} = "Failed";
    $response->{message} = "Not our turn $weare $ksgameshared::gamedata->{turn} ";
    ksgameshared::end($response);
}
my $trigger= param("trigger");
my $target = param("target");
my @targets;

my $lane=param("target");
my $targets = from_json($lane);
my @targets2;
foreach my $target (@{$targets}){
        if      ($target=~/^l(\d)$/){
            if  (!ksgameshared::checktarget($ksgameshared::alltriggers->{$trigger}{targetindex}, $ksgameshared::gamedata->{lane}{$weare}{$1}, $weare ) ){
                $response->{status} = "Failed";
                $response->{message} = "invalid target";
                ksgameshared::end($response);
            }
            push (@targets2,  $ksgameshared::gamedata->{lane}{$weare}{$1});
        }
        if ($target=~/^ol(\d)$/){
            if  (!ksgameshared::checktarget($ksgameshared::alltriggers{$trigger}{targetindex}, $ksgameshared::gamedata->{lane}{$opp}{$1}, $weare ) ){
                $response->{status} = "Failed";
                $response->{message} = "invalid target";
                ksgameshared::end($response);
            }
            push (@targets2, $ksgameshared::gamedata->{lane}{$opp}{$1});
        }
        if ($target=~/^(\d+)$/){
			if  (!ksgameshared::checktarget($ksgameshared::alltriggers{$trigger}{targetindex}, $1, $weare ) ){
                $response->{status} = "Failed";
                $response->{message} = "invalid target: $1";
                ksgameshared::end($response);
            }
            push (@targets2, $1);
        }
}
my @effects = split(/,/, $ksgameshared::alltriggers->{$trigger}{effectindexes});
foreach my $effect (@effects){
    ksgameshared::applyeffects({
    	effecttype => $ksgameshared::alleffects->{$effect}{effecttype}, 
    	effecttarget => $ksgameshared::alleffects->{$effect}{effecttarget},
    	effectmod1 => $ksgameshared::alleffects->{$effect}{effectmod1},
    	target =>  \@targets2, 
    	effectcontroller => $weare,
    	});
}


shift(@{$ksgameshared::gamedata->{forceplay}});
if ( (scalar @{$ksgameshared::gamedata->{forceplay}}) == 0){
	ksgameshared::checkplays();
    delete ($ksgameshared::gamedata->{forceplay});
}else {
    my $string = to_json($ksgameshared::gamedata->{forceplay}[0]);
    $ksgameshared::dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, `forcedaction`) VALUES(?, ? )", undef, (0,  $string));
		
}



ksgameshared::savegame($game);
$response->{messages}=ksgameshared::sendnewmessages($game);
ksgameshared::end($response);
