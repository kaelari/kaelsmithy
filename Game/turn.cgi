#!/usr/bin/perl -w
use lib qw(. /usr/lib/cgi-bin/game);
use CGI qw(param);
use List::Util 'shuffle';
use JSON;
my $response = {};
$ksgameshared::dbh=ksdb::connectdb();
ksgameshared::init();
unless ($ksgameshared::loggedin){
    ksgameshared::end();
    exit;
}
my $game=param("game");
ksgameshared::loadgame($game);
if ($ksgameshared::gamedata->{ended}>0){
	$response->{status} = "Failed";
    $response->{message} = "Game has ended";
    ksgameshared::end($response);
}
if ($ksgameshared::gamedata->{forceplay}){
    $response->{status} = "Failed";
    $response->{message} = "Must do forced play first";
    ksgameshared::end($response);
}

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
    $response->{message} = "Not our turn";
    ksgameshared::end($response);
}
if ($ksgameshared::gamedata->{turnphase} == 0){
    #time to B-B-Battle
    ksgameshared::checktriggers("Attack");
    our $lanestring="";
    #if niether ship exists or both have summoning sickness
    for my $lane (1..5){
    	my $battle1 = ksgameshared::checkcanbattle($ksgameshared::gamedata->{lane}{1}{$lane});
    	my $battle2 = ksgameshared::checkcanbattle($ksgameshared::gamedata->{lane}{2}{$lane});
        if ( $battle1==0 and  $battle2==0) {
            next;
        }
        my $damage = 0;
        if ( $battle1 and $ksgameshared::gamedata->{lane}{2}{$lane} == 0) {
            $damage = $ksgameshared::gamedata->{objects}{ $ksgameshared::gamedata->{lane}{1}{$lane} }{"Attack"};
            if ($damage > 0 ) {
				$ksgameshared::gamedata->{players}{2}{life}-= $damage;
				if (ksgameshared::checkkeyword("Drain", $ksgameshared::gamedata->{lane}{1}{$lane}) ) {
						$ksgameshared::gamedata->{players}{1}{life} += $damage;
				}
            }
            ksgameshared::logmessage("$ksgameshared::gamedata->{players}{2}{name} takes $damage damage");
        }
        if ($ksgameshared::gamedata->{lane}{1}{$lane} ==0 and $battle2) {
            $damage = $ksgameshared::gamedata->{objects}{ $ksgameshared::gamedata->{lane}{2}{$lane} }{"Attack"};
            if ($damage > 0){
				$ksgameshared::gamedata->{players}{1}{life}-= $damage;
				if (ksgameshared::checkkeyword("Drain", $ksgameshared::gamedata->{lane}{2}{$lane} ) ) {
						$ksgameshared::gamedata->{players}{2}{life} += $damage;
				}
            }
            ksgameshared::logmessage("$ksgameshared::gamedata->{players}{1}{name} takes $damage damage");
        }
        if ($ksgameshared::gamedata->{lane}{1}{$lane} >=1 and $ksgameshared::gamedata->{lane}{2}{$lane} >= 1) {
            #player1's creature first (but actually at the same time)
            $damage = $ksgameshared::gamedata->{objects}{ $ksgameshared::gamedata->{lane}{1}{$lane} }{"Attack"};
           
            if ($damage >0 ){
                $ksgameshared::gamedata->{objects}{ $ksgameshared::gamedata->{lane}{2}{$lane} }{"Health"}-=$damage;
                if (ksgameshared::checkkeyword("Drain", $ksgameshared::gamedata->{lane}{1}{$lane} )) {
					$ksgameshared::gamedata->{players}{1}{life} += $damage;
				}
				if (ksgameshared::checkkeyword("Relentless", $ksgameshared::gamedata->{lane}{1}{$lane}) and $ksgameshared::gamedata->{objects}{ $ksgameshared::gamedata->{lane}{2}{$lane} }{"Health"} < 0 and $battle1){
					$ksgameshared::gamedata->{players}{2}{life}  += $ksgameshared::gamedata->{objects}{ $ksgameshared::gamedata->{lane}{2}{$lane} }{"Health"};
				}
            }
            
            #player2's creature hits back at the same time
            $damage = $ksgameshared::gamedata->{objects}{ $ksgameshared::gamedata->{lane}{2}{$lane} }{"Attack"};
            
            if ($damage >0 ){
                $ksgameshared::gamedata->{objects}{ $ksgameshared::gamedata->{lane}{1}{$lane} }{"Health"}-=$damage;
                if (ksgameshared::checkkeyword("Drain", $ksgameshared::gamedata->{lane}{2}{$lane})) {
					$ksgameshared::gamedata->{players}{2}{life} += $damage;
				}
				if (ksgameshared::checkkeyword("Relentless", $ksgameshared::gamedata->{lane}{2}{$lane}) and $ksgameshared::gamedata->{objects}{ $ksgameshared::gamedata->{lane}{1}{$lane} }{"Health"} < 0  and $battle2){
					$ksgameshared::gamedata->{players}{1}{life}  += $ksgameshared::gamedata->{objects}{ $ksgameshared::gamedata->{lane}{1}{$lane} }{"Health"};
				}

            }
            
            my $objectstring = "$ksgameshared::gamedata->{lane}{1}{$lane}:".to_json($ksgameshared::gamedata->{objects}{ $ksgameshared::gamedata->{lane}{1}{$lane} });
            $ksgameshared::dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, `object`) VALUES(?, ? )", undef, (0, $objectstring ));
            $objectstring = "$ksgameshared::gamedata->{lane}{2}{$lane}:".to_json($ksgameshared::gamedata->{objects}{$ksgameshared::gamedata->{lane}{2}{$lane}});
            $ksgameshared::dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, `object`) VALUES(?, ? )", undef, (0, $objectstring ));
    
            
            
        }
       
        
    }
    my $healthstring="1:$ksgameshared::gamedata->{players}{1}{life};2:$ksgameshared::gamedata->{players}{2}{life}";
    $ksgameshared::dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, life) VALUES(?, ? )", undef, (0, $healthstring ) );
    ksgameshared::logmessage("Combat Over");
    ksgameshared::checkendgame();
    $ksgameshared::gamedata->{turnphase} = 1;
}else {
    ksgameshared::logmessage("$ksgameshared::player->{username} ended their turn");
    $ksgameshared::gamedata->{players}{$ksgameshared::gamedata->{turn} }{levelprogress} += 1;
    warn "calling discard!";
    ksgameshared::discard($ksgameshared::gamedata->{turn});
    
    
    
    if ($ksgameshared::gamedata->{players}{$ksgameshared::gamedata->{turn} }{levelprogress} >= 4) {
        $ksgameshared::gamedata->{players}{$ksgameshared::gamedata->{turn} }{levelprogress} = 0;
        $ksgameshared::gamedata->{players}{$ksgameshared::gamedata->{turn} }{level} += 1;
        #need to move all cards from the discard to the player's deck and then shuffle;
        my $weare = $ksgameshared::gamedata->{turn};
        ksgameshared::shufflediscardintodeck($weare);
        
        
        ksgameshared::logmessage("$ksgameshared::player->{username} has leveled up!");
   
    }
    
    ksgameshared::drawcard($ksgameshared::gamedata->{turn} , 6);
    
    
    $ksgameshared::gamedata->{turnphase}=0;
    $ksgameshared::gamedata->{turn}+=1;
    if ($ksgameshared::gamedata->{turn}>=3){
        $ksgameshared::gamedata->{turn}=1;
    }
    $ksgameshared::gamedata->{playsremaining}=2;
    delete $ksgameshared::gamedata->{hidden}{$weare}{handplayable};
    $ksgameshared::dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, `turn`, `handplayable`) VALUES(?, ?, ?)", undef, ($ksgameshared::gamedata->{players}{ $weare }{playerid}, $ksgameshared::gamedata->{turn}, "[]"));
    foreach my $a (1..5) {
		if (my $object=$ksgameshared::gamedata->{lane}{ $ksgameshared::gamedata->{turn} }{$a}) {
			$ksgameshared::gamedata->{objects}{$object}{activatedthisturn}=0;
			my $changed=0;
			if ((my $decay= ksgameshared::checkkeyword("Decay", $object) )> 0 ){
				$ksgameshared::gamedata->{objects}{$object}{Attack}-= $decay;
				$ksgameshared::gamedata->{objects}{$object}{Health}-= $decay;
				$ksgameshared::gamedata->{objects}{$object}{maxhealth}-= $decay;
				$changed=1;
			}
			if ((my $repair= ksgameshared::checkkeyword("Repair", $object) )> 0 ){
				$ksgameshared::gamedata->{objects}{$object}{Health}+= $repair;
				if ($ksgameshared::gamedata->{objects}{$object}{Health} > $ksgameshared::gamedata->{objects}{$object}{maxhealth}){
					$ksgameshared::gamedata->{objects}{$object}{Health} = $ksgameshared::gamedata->{objects}{$object}{maxhealth};
				}
				$changed=1;
			}
			if  ($ksgameshared::gamedata->{objects}{$object}{ss}) {
				$ksgameshared::gamedata->{objects}{$object}{ss}=0;
				$changed=1;
			}
			if ($changed){
				my $objectstring = "$object:".to_json($ksgameshared::gamedata->{objects}{$object });
				$ksgameshared::dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, `object`) VALUES(?, ? )", undef, (0, $objectstring ));
            }
		}
		if (my $object=$ksgameshared::gamedata->{lane}{ (($ksgameshared::gamedata->{turn} % 2) +1) }{$a}) {
			my $changed=0;
			if ((my $decay= ksgameshared::checkkeyword("Decay", $object) )> 0 ){
				$ksgameshared::gamedata->{objects}{$object}{Attack}-= $decay;
				$ksgameshared::gamedata->{objects}{$object}{Health}-= $decay;
				$ksgameshared::gamedata->{objects}{$object}{maxhealth}-= $decay;
				$changed=1;
			}
			if ((my $repair= ksgameshared::checkkeyword("Repair", $object) )> 0 ){
				$ksgameshared::gamedata->{objects}{$object}{Health}+= $repair;
				if ($ksgameshared::gamedata->{objects}{$object}{Health} > $ksgameshared::gamedata->{objects}{$object}{maxhealth}){
					$ksgameshared::gamedata->{objects}{$object}{Health} = $ksgameshared::gamedata->{objects}{$object}{maxhealth};
				}
				$changed=1;
			}
			if ($changed){
				my $objectstring = "$object:".to_json($ksgameshared::gamedata->{objects}{$object });
				$ksgameshared::dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, `object`) VALUES(?, ? )", undef, (0, $objectstring ));
            }
		}
    }
    ksgameshared::checktriggers("startturn");
    ksgameshared::checkstatebased($game);
    ksgameshared::checkplays();
    ksgameshared::logmessage("$ksgameshared::gamedata->{players}{$ksgameshared::gamedata->{turn}}{name} begins their turn.");
}



my $levelstring = "1:$ksgameshared::gamedata->{players}{1}{level} - $ksgameshared::gamedata->{players}{1}{levelprogress};2:$ksgameshared::gamedata->{players}{2}{level} - $ksgameshared::gamedata->{players}{2}{levelprogress}";
$ksgameshared::dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, `levels`) VALUES(?, ?)", undef, (0, $levelstring));

ksgameshared::savegame($game);
$response->{messages}=ksgameshared::sendnewmessages($game);

ksgameshared::end($response);
