#!/usr/bin/perl -w
use strict "vars";
use lib qw(. /usr/lib/cgi-bin/platform);
use dbconnect2;
my $dbh=db::connectdb();

my $achievements =$dbh->selectall_arrayref("SELECT * from `Achievements` WHERE `expires` = \"weekly\"", {Slice=>{}});
my $string;
my @ids;
foreach my $achievement (@$achievements){
	push (@ids, $achievement->{achievementId});
}
$string = join(",", @ids);
$dbh->do("delete from `PlayerAchievements` WHERE `achievementId` in ($string)");
