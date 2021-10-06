#!/usr/bin/perl -w
use strict;
use lib qw(. /usr/lib/cgi-bin/ks);
use CGI qw(param);
$ksgameshared::dbh=ksdb::connectdb();
my $response = {};
ksgameshared::init();
unless ($ksgameshared::loggedin){
    ksgameshared::end();
    exit;
}
my $game=param("game");
$ksgameshared::game = $game;
ksgameshared::loadgame($game);

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

$ksgameshared::gamedata->{players}{$weare}{life}=-1000;

ksgameshared::checkendgame();

$response->{messages} = ksgameshared::sendnewmessages($game);
ksgameshared::savegame($game);
ksgameshared::end($response);
