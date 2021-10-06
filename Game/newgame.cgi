#!/usr/bin/perl -w
use lib qw(. /usr/lib/cgi-bin/ksgame);
use CGI qw(param);
use List::Util 'shuffle';
use Data::Dumper;
my $response = {};
$ksgameshared::dbh=ksdb::connectdb();
my $player1=(param("player1") or "");
my $player2=(param("player2") or "");
my $deck1=(param("deck1") or "");
my $deck2=(param("deck2") or "");
my $gameid=(param("gameid") or "");
my $name1=(param("player1name") or "");
my $name2=(param("player2name") or "");
if ($player1 and $player2 and $deck1 and $deck2 and $gameid){	
	startgame($gameid, $player1, $player2, $deck1, $deck2, $name1, $name2);
}else {
	ksgameshared::debuglog("Error! missing data to make game: $player1 and $player2 and $deck1 and $deck2 and $gameid");
}

sub startgame {
	my $gameid=shift;
	my $player1=shift;
	my $player2=shift;
	my $deck1 =shift;
	my $deck2 = shift;
	my $name1= shift;
	my $name2=shift;
 	$ksgameshared::game = $gameid;
	$ksgameshared::dbh->do("CREATE TABLE `KS_game`.`GameMessages_$gameid` (
   `playerid` int(11) NOT NULL,
  `messageid` int(11) NOT NULL,
  `logmessage` char(255) DEFAULT NULL,
  `changezones` char(255) DEFAULT NULL,
  `changestate` char(255) DEFAULT NULL,
  `changeowner` char(255) DEFAULT NULL,
  `changeposition` char(255) DEFAULT NULL,
  `forcedaction` char(255) DEFAULT NULL,
  `turn` int(4) DEFAULT NULL,
  `levels` char(255) DEFAULT NULL,
  `moveoptions` char(255) DEFAULT NULL,
  `draws` char(10) DEFAULT NULL,
  `handplayable` text CHARACTER SET utf8 COLLATE utf8_unicode_ci DEFAULT NULL,
  `gold` char(255) DEFAULT NULL,
  `life` char(255) NOT NULL,
  `threshold` char(255) NOT NULL,
  `lane` char(255) NOT NULL,
  `stationlane` char(255) NOT NULL,
  `object` text CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL,
  `ended` char(2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;");
	$ksgameshared::dbh->do("ALTER TABLE `KS_game`.`GameMessages_$gameid` ADD PRIMARY KEY (`messageid`);");
	$ksgameshared::dbh->do("ALTER TABLE `KS_game`.`GameMessages_$gameid`
  MODIFY `messageid` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;");
	srand;
	$ksgameshared::gamedata={};
	$ksgameshared::gamedata->{turn}=int rand(2)+1;
	$ksgameshared::gamedata->{turnphase}=0;
	$ksgameshared::gamedata->{playsremaining}=1;
	
	$ksgameshared::gamedata->{ended}=0;
	$ksgameshared::gamedata->{lane}= {
				'2' => {
                               '3' => 0,
                               '4' => 0,
                               '5' => 0,
                               '2' => 0,
                               '1' => 0
                             },
                      '1' => {
                               '1' => 0,
                               '5' => 0,
                               '2' => 0,
                               '3' => 0,
                               '4' => 0
                             }
	};
	
	$ksgameshared::gamedata->{players}{1} = {
			threshold => {},
			life => 125,
			moves => 3,
			hand => [],
			playerid => $player1,
			name => $name1,
			id => 1,
			level => 1,
			levelprogress=> 0,
			};
	
	$ksgameshared::gamedata->{players}{2} = {
			threshold => {},
			life => 125,
			moves => 3,
			hand => [],
			playerid => $player2,
			name => $name2,
			id => 2,
			level => 1,
			levelprogress=> 0,
			};
	$ksgameshared::gamedata->{objectnumber} = 1;
	my @deck1 = split(/, ?/, $deck1);
	my @deck2 = split(/, ?/, $deck2);
	my @newdeck1;
	my @newdeck2;
	
	foreach my $card (@deck1){
		my $objectnumber = ksgameshared::createobject($card, 1, 0);
		$ksgameshared::gamedata->{objects}{$objectnumber}{zone}="deck";
		push (@newdeck1, $objectnumber);
	}
	foreach my $card (@deck2){
		my $objectnumber = ksgameshared::createobject($card, 2, 0);
		$ksgameshared::gamedata->{objects}{$objectnumber}{zone}="deck";
		push (@newdeck2, $objectnumber);
	}
	@deck1 = shuffle (@newdeck1);
	@deck2 = shuffle (@newdeck2);
	$ksgameshared::gamedata->{deck1}=\@deck1;
	$ksgameshared::gamedata->{deck2}=\@deck2;
	ksgameshared::drawcard(1, 6);
	ksgameshared::drawcard(2, 6);
	ksgameshared::checkplays();
	$ksgameshared::dbh->do("INSERT INTO `KS_game`.`GameData` (`gameid`, `data`) VALUES(?, ?);", undef, ($gameid, Data::Dumper::Dumper($ksgameshared::gamedata)));
	

}
