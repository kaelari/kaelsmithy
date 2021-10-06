#!/usr/bin/perl -w
use lib qw(. /usr/lib/cgi-bin/ksplatform);
use ksdbconnect;
use Data::Dumper;
use List::Util 'shuffle';
use Time::HiRes qw(usleep);

our $dbh=ksdbplatform::connectdb();
for (1..60){
	my $queues = $dbh->selectall_hashref("SELECT DISTINCT(`queuekey`) from `queue`", "queuekey", undef);
	foreach my $queue (keys %{$queues}){
		print "$queue\n";
		my $entries = $dbh->selectall_arrayref("Select * FROM `queue` WHERE `queuekey` = ? ORDER BY `jointime`", {Slice=>{}}, ($queue));
		my $i=0;
		outer: while (@{$entries} >= 2 and $i < @{$entries}){
			#we have at least 2 people to pair, lets pair them.
			print "at least 2 entries\n";

			my $z=1;
			while ($z < @{$entries}){
				if (canpair($entries->[$i], $entries->[$z])){
					print "can pair!\n";
					print Dumper($entries->[$i]);
					$dbh->do("INSERT INTO `Games` (`player1`, `player2`, `deck1`, `deck2`, eventId1, eventId2) VALUES(?,?,?,?,?,?)", undef, ($entries->[$i]{playerid}, $entries->[$z]{playerid}, $entries->[$i]{deckid}, $entries->[$z]{deckid}, $entries->[$i]{eventid}, $entries->[$z]{eventid}));
					my $game= $dbh->{'mysql_insertid'};
					$dbh->do("Delete from `queue` where `rowid` = ?", undef, ($entries->[$i]{rowid}));
					$dbh->do("Delete from `queue` where `rowid` = ?", undef, ($entries->[$z]{rowid}));
					if ($entries->[$i]{eventid}){
						$dbh->do("UPDATE `Playerevents` set `Status` = 'Playing' WHERE `rowid` = ?", undef, ($entries->[$i]{eventid}));
						$dbh->do("UPDATE `Playerevents` set `Status` = 'Playing' WHERE `rowid` = ?", undef, ($entries->[$z]{eventid}));
					}

					startgame($game, $entries->[$i], $entries->[$z]);
					#do this after the game is started so it's full set up when the client gets the message of a new game. otherwise crashes...
					$dbh->do("INSERT INTO `messages` (`userId`, `message`) VALUES (?, ?)", undef, ($entries->[$i]{playerid}, "GAME STARTED"));
					$dbh->do("INSERT INTO `messages` (`userId`, `message`) VALUES (?, ?)", undef, ($entries->[$z]{playerid}, "GAME STARTED"));
					shift @{$entries};
					shift @{$entries};
					
					next outer;
				}
				$z++;
			}
			$i++;
		}	
	}
	
	usleep(950000);
}

sub canpair {
	my $player1=shift;
	my $player2=shift;
	if ($player1->{playerid} == $player2->{playerid}){
		#we can't play ourself
		return 0;
	}

	#logic should go here...
	return 1;
}

sub startgame {
	my $gameid=shift;
	my $player1=shift;
	my $player2=shift;
	
	my $deck1 = loaddeck( $player1->{deckid} ) ;
	my $deck2 =  loaddeck( $player2->{deckid} ) ;
	use LWP::UserAgent;
	use HTTP::Request;
	$name1=getusername($player1->{playerid});
	$name2=getusername($player2->{playerid});
	my $userAgent = LWP::UserAgent->new();
	my $request = HTTP::Request->new( POST => "https://kaelari.tech/ksgame/newgame.cgi" );
	
	$request->content("password=ajdkhfaksjfhakdsaflkjhas&player1name=$name1&player2name=$name2&gameid=$gameid&deck1=$deck1&deck2=$deck2&player1=$player1->{playerid}&player2=$player2->{playerid}");
	$request->content_type("application/x-www-form-urlencoded");
	my $response = $userAgent->request($request);
	
}


sub loaddeck {
	my $deck=shift;
	my $data=$dbh->selectrow_hashref("SELECT * FROM `Decks` WHERE `deckid` = ?", undef, ($deck));
	
	return $data->{cards};

}

sub getusername{
	my $id=shift;
        return $id unless ($id);
	my $data=$dbh->selectrow_hashref("SELECT * from `Users` where `userId` = ?", undef, $id);
	return $data->{username};
}
