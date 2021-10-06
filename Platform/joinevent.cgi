#!/usr/bin/perl -w
use strict "vars";
use lib qw(. /usr/lib/cgi-bin/ksplatform);
use Digest::MD5 qw(md5_hex);
use CGI param;
$ksplatformshared::dbh=ksdbplatform::connectdb();
my $response = {};
ksplatformshared::init();
if (!$ksplatformshared::loggedin){
    $response->{status}="failed";
    $response->{message}="Not logged in";
    ksplatformshared::end($response);
}
my $event=param("event");
my $sku=param("sku");

my $eventdata=$ksplatformshared::dbh->selectrow_hashref("SELECT * from `events` WHERE `eventid` = ?", undef, ($event));

unless ($eventdata){
    $response->{status}="failed";
    $response->{message}="Event Not Found";
    end($response);

}

#check if we're already in the event
my $eventin = $ksplatformshared::dbh->selectrow_hashref("SELECT * from `Playerevents` WHERE `eventid` = ? and `playerid` = ? and `finished` = 0", undef, ($event, $ksplatformshared::player->{userId}));
if ($eventin){
    $response->{status}="failed";
    $response->{message}="Already joined this event";
    ksplatformshared::end($response);
}


my @costs = split(/,/, $eventdata->{EntryFees});
my $amount=0;
foreach my $cost (@costs){
    my ($costamount, $costsku) = split(/:/, $cost);
    
    if ($costsku eq $sku){
        #this is what we're paying with
        
        $amount = $costamount;
        last;
    }

}
if ($amount == 0 ){
    $response->{status}="failed";
    $response->{message}="Wrong currency selected?";
    
    ksplatformshared::end($response);
}
my $result=$ksplatformshared::dbh->selectrow_hashref("SELECT * from `Inventory` Where `sku` = ? and `number` >= ? and `userId` = ?", undef, ($sku, $amount, $ksplatformshared::player->{userId}));

if (!$result){
    $response->{status}="failed";
    $response->{message}="insufficient currency";
    ksplatformshared::end($response);
}
$ksplatformshared::dbh->do("UPDATE `Inventory` SET `number` = `number` - ? WHERE `rowid` = ?", undef, ($amount, $result->{rowid}));

if ($eventdata->{EventType} eq "Draft"){
    $ksplatformshared::dbh->do("INSERT INTO `Playerevents` (`playerId`, `eventid`, `status`, `gamesneeded`) VALUES(?,?,?, ?)", undef, ($ksplatformshared::player->{userId}, $event, "Drafting", $eventdata->{gamesneeded}));
}else {
    $ksplatformshared::dbh->do("INSERT INTO `Playerevents` (`playerId`, `eventid`, `status`, `gamesneeded`) VALUES(?,?,?, ?)", undef, ($ksplatformshared::player->{userId}, $event, "Entered", $eventdata->{gamesneeded}));
}
$amount=0-$amount;
ksplatformshared::sendmessage("new:$sku:$amount", $ksplatformshared::player->{playerId});


ksplatformshared::end($response);
