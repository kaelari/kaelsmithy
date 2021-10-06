#!/usr/bin/perl -w
use strict "vars";
use lib qw(.);
use Digest::MD5 qw(md5_hex);
use CGI param;
use Data::Dumper;
our $dbh=$ksplatformshared::dbh;
my $response = {};
ksplatformshared::init();
my $achievements;

#get list of all achievements
$response->{"achievements"} = $dbh->selectall_arrayref("SELECT * from `Achievements`", {Slice =>{}});
my $earned = $dbh->selectall_hashref("SELECT * from `playerAchievements` WHERE `userId` = ?", 'achievementId', undef, ($platformshared::player->{userId}));

foreach my $achievement ( @{$response->{"achievements"}}){
    if ($earned->{$achievement->{achievementId}}){
        $achievement->{earned} = $earned->{$achievement->{achievementId}}{completed};
        $achievement->{progress} = $earned->{$achievement->{achievementId}}{progress};
        
    }else {
		$achievement->{earned} = 0;
		$achievement->{progress}=0;
    }
}

#$response->{achievements}=$achievements;

ksplatformshared::end($response);
