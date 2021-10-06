#!/usr/bin/perl -w
use strict;
use lib qw(. /usr/lib/cgi-bin/game);
use CGI qw(param);

my $response = {};
gameshared::init();
unless ($gameshared::loggedin){
    gameshared::end();
    exit;
}
my $game=param("game");
$gameshared::game = $game;
gameshared::loadgame($game);

our $weare=0;
our $opp =0;

if ($gameshared::gamedata->{players}{1}{playerid} != $gameshared::player->{userId}){
    #we are 2
    $weare=2;
    $opp=1;
}else {
    $weare=1;
    $opp=2;
}

gameshared::end($response);
