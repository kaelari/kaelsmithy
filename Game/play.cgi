#!/usr/bin/perl -w
use lib qw(. /usr/lib/cgi-bin/game);
use strict;

$ksgameshared::dbh=ksdb::connectdb();
use CGI qw(param);
import JSON;
my $response = {};
ksgameshared::init();
unless ($ksgameshared::loggedin){
    ksgameshared::ksgameshared::end();
    exit;
}
our $game=param("game");


unless ($game){
    $response->{message}="No gameid";
    $response->{status} = "Failed";
    ksgameshared::end($response);
    exit;
}
ksgameshared::loadgame($game);
if ($ksgameshared::gamedata->{ended} > 0){
    $response->{status} = "Failed";
    $response->{message} = "game has ended";
    ksgameshared::end($response);
    exit;
}

if ($ksgameshared::gamedata->{forceplay}){
    $response->{status} = "Failed";
    $response->{message} = "Must do forced play first";
    ksgameshared::end($response);
    exit;
}
our $weare=0;
our $opp = 0;



if ($ksgameshared::gamedata->{players}{$ksgameshared::gamedata->{turn}}{playerid} != $ksgameshared::player->{userId}){
    #it's not our turn!
    $response->{status} = "Failed";
    $response->{message} = "Not our turn - $ksgameshared::gamedata->{turn} is $ksgameshared::gamedata->{players}{$ksgameshared::gamedata->{turn}}{playerid}";
    ksgameshared::end($response);
    exit;
}

if ($ksgameshared::gamedata->{players}{1}{playerid} != $ksgameshared::player->{userId}){
    #we are 2
    $weare=2;
    $opp=1;
}else {
    $weare=1;
    $opp=2;
}

delete $ksgameshared::gamedata->{hidden}{$weare}{handplayable};



    my $card=param("card");
    #check the card is in fact a Effect;
    if ($ksgameshared::gamedata->{objects}{$card}{CardType} eq "Effect"){
    
        my $lane=param("target");
        my $targets = from_json($lane);    
        my $found = 0;
        my $z=0;
        foreach my $cardinhand (@{$ksgameshared::gamedata->{players}{$ksgameshared::gamedata->{turn} }{hand}}){
            if ($cardinhand == $card){
                $found=1;
                last;
            }
            $z++;
        }
        if ($found == 0) {
            $response->{status} = "Failed";
            $response->{message} = "card not in hand";
            ksgameshared::end($response);
            exit;
        }
		splice @{$ksgameshared::gamedata->{players}{$ksgameshared::gamedata->{turn} }{hand}}, $z, 1;
		$ksgameshared::dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, `draws`) VALUES(?, ?)", undef, ($ksgameshared::player->{userId}, -$card));
   
        my @targets2;
        my $index=0;
        ksgameshared::debuglog(Data::Dumper::Dumper($targets));
        foreach my $targetid (split(/,/, $ksgameshared::gamedata->{objects}{$card}{targets})) {
			if ($ksgameshared::alltargets->{$targetid}{targettype} eq "allships"){
				ksgameshared::debuglog("doing the thing");
				foreach my $lane (1..5){
					if ($ksgameshared::gamedata->{lane}{$weare}{$lane} > 0 ){
					ksgameshared::debuglog("checking friendly lane $lane. $ksgameshared::gamedata->{lane}{$weare}{$lane}");		
						if (!ksgameshared::checktarget($targetid, $ksgameshared::gamedata->{lane}{$weare}{$lane}, $weare ) ){
							next;
						}
						push (@targets2,  $ksgameshared::gamedata->{lane}{$weare}{$lane});
					}
				}
				foreach my $lane(1..5){
					if ($ksgameshared::gamedata->{lane}{$opp}{$lane} > 0){
						ksgameshared::debuglog("checking opponent lane $lane. $ksgameshared::gamedata->{lane}{$opp}{$lane}");		
						if (!ksgameshared::checktarget($targetid, $ksgameshared::gamedata->{lane}{$opp}{$lane}, $weare ) ){
							next;
						}
					
						push (@targets2,  $ksgameshared::gamedata->{lane}{$opp}{$lane});
					}
				}
			}elsif ($ksgameshared::alltargets->{$targetid}{targettype} eq "controller") {
			
			}else {
				
					if ($targets->[$index]=~/^l(\d)$/){
						if (!ksgameshared::checktarget($targetid, $ksgameshared::gamedata->{lane}{$weare}{$1}, $weare ) ){
							$response->{status} = "Failed";
							$response->{message} = "invalid target";
							ksgameshared::end($response);
							exit;
						}
						push (@targets2,  $ksgameshared::gamedata->{lane}{$weare}{$1});
					}
					if ($targets->[$index]=~/^ol(\d)$/){
						if (!ksgameshared::checktarget($targetid, $ksgameshared::gamedata->{lane}{$opp}{$1}, $weare ) ){
							$response->{status} = "Failed";
							$response->{message} = "invalid target";
							ksgameshared::end($response);
						}
						push (@targets2, $ksgameshared::gamedata->{lane}{$opp}{$1});
					}
				 if ($targets->[$index]=~/^(\d+)$/){
					if  (!ksgameshared::checktarget($targetid, $1, $weare ) ){
						$response->{status} = "Failed";
						$response->{message} = "invalid target: $1";
						ksgameshared::end($response);
					}
					push (@targets2, $1);
				}
			}
			$index += 1;
		}
        my @effects = split(/,/, $ksgameshared::gamedata->{objects}{$card}{effects});
        foreach my $effect (@effects){
            if ($ksgameshared::alltargets->{$ksgameshared::gamedata->{objects}{$card}{targets}}{targettype} eq "allships"){
        		ksgameshared::debuglog("applying effect(allships): $effect");
        		foreach my $target (@targets2){
					ksgameshared::applyeffects( {
						effecttype=> $ksgameshared::alleffects->{$effect}{effecttype}, 
						effecttarget => $ksgameshared::alleffects->{$effect}{effecttarget},
						effectmod1 => $ksgameshared::alleffects->{$effect}{effectmod1}, 
						target => [$target], 
						effectcontroller => $weare,
						} );
        		}
        	}else {
        		ksgameshared::debuglog("applying effect: $effect");
				ksgameshared::applyeffects( {
					effecttype => $ksgameshared::alleffects->{$effect}{effecttype}, 
					effecttarget => $ksgameshared::alleffects->{$effect}{effecttarget},
					effectmod1 => $ksgameshared::alleffects->{$effect}{effectmod1},
					target => \@targets2,
					effectcontroller => $weare, 
					} );
            }
        }
     $ksgameshared::gamedata->{objects}{$card}{zone}="graveyard";
    ksgameshared::debuglog("card is: $card");
    
    if ($targets2[0]){
    	my $message = " $ksgameshared::player->{username} plays <link=$ksgameshared::gamedata->{objects}{$card}{CardId}><color=#000000>$ksgameshared::gamedata->{objects}{$card}{Name}(lvl $ksgameshared::gamedata->{objects}{$card}{level})</color></link> targetting ";
    	for (my $i=0; $i<scalar @targets2; $i++){
			if ($i>0) {
				$message.=" and ";
			}
			$message .= "<link=$ksgameshared::gamedata->{objects}{$targets2[$i]}{CardId}><color=#000000>$ksgameshared::gamedata->{objects}{$targets2[$i] }{Name}</color></link>";
    	}
        ksgameshared::logmessage($message);
    }else {
        ksgameshared::logmessage("$ksgameshared::player->{username} plays <link=$ksgameshared::gamedata->{objects}{$card}{CardId}><color=#000000>$ksgameshared::gamedata->{objects}{$card}{Name}(lvl $ksgameshared::gamedata->{objects}{$card}{level})</color></link>.");
    }
    if (ksgameshared::checkkeyword("Free", $card) > 0 ) {
    	ksgameshared::debuglog("This card is free");
    }else {
		$ksgameshared::gamedata->{playsremaining} -= $ksgameshared::gamedata->{objects}{$card}{cost};
    }
    

}elsif ($ksgameshared::gamedata->{objects}{$card}{CardType} eq "Ship" and $ksgameshared::gamedata->{objects}{$card}{zone} eq "play")  {
	ksgameshared::debuglog("This is an activated ability");
	my $activated = $ksgameshared::allactivated->{ $ksgameshared::gamedata->{objects}{$card}{activated}}{targetindex};
	my $lane=param("target");
    my $targets = from_json($lane);    
       
	my @targets2;
        my $index=0;
        ksgameshared::debuglog(Data::Dumper::Dumper($targets));
	foreach my $targetid (split(/,/, $activated)) {
			if ($ksgameshared::alltargets->{$targetid}{targettype} eq "allships"){
				ksgameshared::debuglog("doing the thing");
				foreach my $lane (1..5){
					if ($ksgameshared::gamedata->{lane}{$weare}{$lane} > 0 ){
					ksgameshared::debuglog("checking friendly lane $lane. $ksgameshared::gamedata->{lane}{$weare}{$lane}");		
						if (!ksgameshared::checktarget($targetid, $ksgameshared::gamedata->{lane}{$weare}{$lane}, $weare ) ){
							next;
						}
						push (@targets2,  $ksgameshared::gamedata->{lane}{$weare}{$lane});
					}
				}
				foreach my $lane(1..5){
					if ($ksgameshared::gamedata->{lane}{$opp}{$lane} > 0){
						ksgameshared::debuglog("checking opponent lane $lane. $ksgameshared::gamedata->{lane}{$opp}{$lane}");		
						if (!ksgameshared::checktarget($targetid, $ksgameshared::gamedata->{lane}{$opp}{$lane}, $weare ) ){
							next;
						}
					
						push (@targets2,  $ksgameshared::gamedata->{lane}{$opp}{$lane});
					}
				}
			}elsif ($ksgameshared::alltargets->{$targetid}{targettype} eq "controller") {
			
			}else {
				
					if ($targets->[$index]=~/^l(\d)$/){
						if (!ksgameshared::checktarget($targetid, $ksgameshared::gamedata->{lane}{$weare}{$1}, $weare ) ){
							$response->{status} = "Failed";
							$response->{message} = "invalid target";
							ksgameshared::end($response);
							exit;
						}
						push (@targets2,  $ksgameshared::gamedata->{lane}{$weare}{$1});
					}
					if ($targets->[$index]=~/^ol(\d)$/){
						if (!ksgameshared::checktarget($targetid, $ksgameshared::gamedata->{lane}{$opp}{$1}, $weare ) ){
							$response->{status} = "Failed";
							$response->{message} = "invalid target";
							ksgameshared::end($response);
						}
						push (@targets2, $ksgameshared::gamedata->{lane}{$opp}{$1});
					}
				 if ($targets->[$index]=~/^(\d+)$/){
					if  (!ksgameshared::checktarget($targetid, $1, $weare ) ){
						$response->{status} = "Failed";
						$response->{message} = "invalid target: $1";
						ksgameshared::end($response);
					}
					push (@targets2, $1);
				}
			}
			$index += 1;
		}
        my @effects = split(/,/, $ksgameshared::allactivated->{ $ksgameshared::gamedata->{objects}{$card}{activated}}{effects});
        foreach my $effect (@effects){
            if ($ksgameshared::alltargets->{$ksgameshared::gamedata->{objects}{$card}{targets}}{targettype} eq "allships"){
        		foreach my $target (@targets2){
					ksgameshared::applyeffects( {
						effecttype => $ksgameshared::alleffects->{$effect}{effecttype},
						effecttarget => $ksgameshared::alleffects->{$effect}{effecttarget},
						effectmod1 => $ksgameshared::alleffects->{$effect}{effectmod1}, 
						target => [$target], 
						effectcontroller => $weare,
						} );
        		}
        	}else {
        		ksgameshared::debuglog("applying effect: $effect");
				ksgameshared::applyeffects({
					effecttype => $ksgameshared::alleffects->{$effect}{effecttype}, 
					effecttarget => $ksgameshared::alleffects->{$effect}{effecttarget},
					effectmod1 => $ksgameshared::alleffects->{$effect}{effectmod1},
					target => \@targets2,
					effectcontroller => $weare,
					} );
            }
        }
		$ksgameshared::gamedata->{objects}{$card}{activatedthisturn}=1;
}elsif($ksgameshared::gamedata->{objects}{$card}{CardType} eq "Ship"){
    my $lane=param("target");
    my $target = from_json($lane);
    if (!$target->[0] || $target->[0] =~/o/){
        $response->{status} = "Failed";
        $response->{message} = "must play to a lane: ".Data::Dumper::Dumper($target->[0]);
        ksgameshared::end($response);
    }
    $lane = $target->[0];
    $lane =~s/l//;
    #check the card is in fact in our hand
    my $found = 0;
    my $z=0;
    foreach my $cardinhand (@{$ksgameshared::gamedata->{players}{$ksgameshared::gamedata->{turn} }{hand}}){
        if ($cardinhand == $card){
            $found=1;
            last;
        }
        $z++;
    }
    if ($found == 0) {
        $response->{status} = "Failed";
        $response->{message} = "card not in hand";
        ksgameshared::end($response);
    }
    #card in hand, check we have resources for it
    if ($ksgameshared::gamedata->{objects}{$card}{cost} > $ksgameshared::gamedata->{playsremaining} and ksgameshared::checkkeyword("Free", $card) <=0){
        #cost is more than we have
        $response->{status} = "Failed";
        $response->{message} = "not enough actions";
        ksgameshared::end($response);
    }
    
    
    #we have enough gold, and threshold, we can recruit this unit... 
        
    splice @{$ksgameshared::gamedata->{players}{$ksgameshared::gamedata->{turn} }{hand}}, $z, 1;
    if (ksgameshared::checkkeyword("Free", $card) > 0 ) {
    	ksgameshared::debuglog("This card is free");
    }else {
		$ksgameshared::gamedata->{playsremaining} -= $ksgameshared::gamedata->{objects}{$card}{cost};
    }
    $ksgameshared::gamedata->{objects}{$card}{zone}="play";
    $ksgameshared::gamedata->{objects}{$card}{lane}="$lane";
    $ksgameshared::gamedata->{objects}{$card}{maxhealth} =$ksgameshared::gamedata->{objects}{$card}{Health};
    $ksgameshared::gamedata->{objects}{$card}{ss}=1;
    my $objectstring = "$card:".to_json($ksgameshared::gamedata->{objects}{$card});
    #Clean up if theres already a Ship here.
    if ($ksgameshared::gamedata->{lane}{$weare}{$lane} > 0 ){
    	$ksgameshared::gamedata->{objects}{ $ksgameshared::gamedata->{lane}{$weare}{$lane} }{zone}="raveyard";
    	$ksgameshared::gamedata->{objects}{ $ksgameshared::gamedata->{lane}{$weare}{$lane} }{lane}=0;
        $ksgameshared::dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, `lane`) VALUES(?, ?)", undef, (0, "$weare:$lane:0"));
    
    }
    $ksgameshared::gamedata->{lane}{ $ksgameshared::gamedata->{turn} }{$lane} = $card;
    $ksgameshared::dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, `lane`, `object`) VALUES(?, ?, ? )", undef, (0, "$weare:$lane:$card", $objectstring ));
    
    ksgameshared::logmessage("$ksgameshared::player->{username} plays <link=$ksgameshared::gamedata->{objects}{$card}{CardId}><color=#000000>$ksgameshared::gamedata->{objects}{$card}{Name}(lvl $ksgameshared::gamedata->{objects}{$card}{level})</color></link>");
    ksgameshared::checktriggers("Shiptrained", $ksgameshared::gamedata->{objects}{$card});
    ksgameshared::debuglog("done checking triggers for shiptrained");

    
    $ksgameshared::dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, `draws`) VALUES(?, ?)", undef, ($ksgameshared::player->{userId}, -$card));
    
    ;
    
}
if ($ksgameshared::gamedata->{objects}{$card}{levelsto}>0){
    #need to add the leveled version to the discard
    my $card= ksgameshared::createobject($ksgameshared::gamedata->{objects}{$card}{levelsto}, $weare);
    $ksgameshared::gamedata->{objects}{$card}{zone}="discard";
    push (@{$ksgameshared::gamedata->{players}{$weare}{discard}}, $card);    
}

ksgameshared::checkstatebased($game);
ksgameshared::checkplays();
ksgameshared::savegame($game);

$response->{messages}=ksgameshared::sendnewmessages($game);

ksgameshared::end($response);
