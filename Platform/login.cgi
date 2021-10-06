#!/usr/bin/perl
use strict "vars";

use lib qw(. /usr/lib/cgi-bin/ksplatform);
use Digest::MD5 qw(md5_hex);
use shared;
use CGI param;
use Data::Dumper;
my $ip=$ENV{'REMOTE_ADDR'};
my $response={};
$ksplatformshared::dbh=ksdbplatform::connectdb();
my %input;
foreach my $a (qw(username password)){
	if (param($a)){
		$input{$a}=param($a);
	}
}


if (!$input{username} or !$input{password}){
    $response->{status}="Failed";    
    $response->{message}="no username or password Failed";    
    ksplatformshared::end($response);
}

my $sql = "SELECT * from `UserLogin` WHERE `email` = ?";
my $hashref = $ksplatformshared::dbh->selectrow_hashref($sql, undef, ($input{username}));

if (!$hashref->{email}){
    $response->{status}="Failed";
    $response->{message}="No username in db: '$input{username}'".Dumper($hashref);
    ksplatformshared::end($response);
}
my $playerdata = $ksplatformshared::dbh->selectrow_hashref("SELECT * from `Users` WHERE `userid` = ?", undef, ($hashref->{userId}));
my $sid;    
my $password=param("password");
if ( (crypt($password, $playerdata->{password}) eq $playerdata->{password}) and $hashref->{email}  ) {
# successful login
    
    for (1..40){
        $sid .= ('.', '/', 0..9, 'A'..'Z', 'a'..'z')[rand 64];    
    }
    $ksplatformshared::dbh->do("INSERT INTO `sessionId`(session, userid) VALUES(?, ?)", undef, ($sid, $hashref->{userId}));
    $response->{session}=$sid;
    $response->{status}="Success";   
    $response->{lastNumber} = $ksplatformshared::dbh->selectrow_arrayref("SELECT `messageId` from `messages` ORDER BY `messageId` DESC limit 1", undef)->[0];
	$playerdata->{password} = "";
	$response->{playerid} = $playerdata->{userId};
    ksplatformshared::grantachievement($hashref->{userId}, 1);
    if (ksplatformshared::grantachievement($hashref->{userId}, 2)) {	
		ksplatformshared::addachievement($hashref->{userId}, 3, 1);
    }
    ksplatformshared::end($response);
    
}else {
#bad pw
    $response->{status}="Failed";    
    
    
    ksplatformshared::end($response);

}
