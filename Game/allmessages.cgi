#!/usr/bin/perl -w
use strict;
use lib qw(. /usr/lib/cgi-bin/ks);
use CGI qw(param);

use JSON;
our $platformdb = 'KS_Platform';
our $dbh=ksdb::connectdb();
our $loggedin = 0;
our $player = "";

my $response = {};
initquiet();
unless ($loggedin){
    $response->{status}= "Failed";
    $response->{reason} = "No session";
    end($response);
    exit;
}


my $game=param("game");
if (!$game) {
    $response->{status}= "Failed";
    $response->{reason} = "No game!";
    end($response);
    
}
#loadgame($game);


my $startmessage= param("startmessage");
if ($startmessage){
    $response->{messages}=$dbh->selectall_arrayref("SELECT * from `GameMessages_$game` WHERE `messageid` > ? AND (`playerid`= ? or `playerid` = 0) ORDER BY `messageid` ASC", {Slice =>{}}, ($startmessage, $player->{userId}));
}else{
    $response->{messages}=$dbh->selectall_arrayref("SELECT * from `GameMessages_$game` WHERE `playerid`= ? or `playerid` = 0 ORDER BY `messageid` ASC", {Slice =>{}}, ($player->{userId}));
}

end($response);

sub initquiet {
	my $sid = param("session");
	my $sql = "SELECT * from $platformdb.sessionId WHERE `session` like ?;";
	my $sessiondata=$dbh->selectrow_hashref($sql, undef, ($sid));
	$sql="SELECT * from $platformdb.`Users` where `userId` = ?;";
	$player = $dbh->selectrow_hashref($sql, undef, $sessiondata->{userId});

	if ($player->{userId}){    
            $loggedin=1;
	}
	
}

sub end {
    my $result=shift;
    if (!$result->{status}){
        $result->{status}= "Success";
    }
    my $response = to_json($result);
    print "Content-Type: Text/JSON\n\n";
    print "$response";
    
    exit;
    
}
