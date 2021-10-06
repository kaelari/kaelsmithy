package ksgameshared;
use strict;
use warnings FATAL => 'all';
use CGI::Carp qw(fatalsToBrowser);
use CGI qw(param);
use POSIX qw(ceil floor);
use Data::Dumper;
use CGI::Cookie;
use DateTime;
use JSON;
use IO::Handle;
use List::Util 'shuffle';

our $platformdb = 'KS_Platform';
our $player;
our $dbh;
our $gamedata;
our $allcards;
our $game;
our $loggedin=0;
our $alltriggers;
our $alltargets;
our $allactivated;
our $logfilehandle;

require ("/usr/lib/cgi-bin/ksgame/ksdb.pm");
$ksgameshared::dbh=ksdb::connectdb();

$allcards=loadcards();
$alltriggers=loadtriggers();
$alltargets=loadtargets();
$allactivated = loadactivated();
our $alleffects = loadeffects();
our $allstatic = loadstatic();

open($logfilehandle, ">>", "/var/log/ladder/KSgame.log") or die ($_);
$logfilehandle->autoflush;
debuglog("started");


sub debuglog {
	print $logfilehandle @_;
	print $logfilehandle "\n";
}

sub init {
	$loggedin=0;
	initquiet();
}
sub initquiet {
	my %cookies = CGI::Cookie->fetch;
	$ksgameshared::dbh=ksdb::connectdb();

	$dbh->do("USE `KS_game`");

	my $sid = param("session");

	my $sql = "SELECT * from $platformdb.sessionId WHERE session like ?;";
	my $sessiondata=$dbh->selectrow_hashref($sql, undef, ($sid));
	$sql="SELECT * from $platformdb.`Users` where `userId` = ?;";
	$player = $dbh->selectrow_hashref($sql, undef, $sessiondata->{userId});



	if ($player->{userId}){
            $loggedin=1;
	}else {
		$loggedin = 0;
	}

}

sub loadgame {
    my $gamenumber=shift;
	$game=$gamenumber;
    my $dbdata=$dbh->selectrow_hashref("SELECT * from `GameData` WHERE `gameid` = ?", undef, ($gamenumber));
    if (!$dbdata->{data}){ 
    }else {
    	local $@;
		$gamedata=eval("my $dbdata->{data}");
		if (!$gamedata){
			warn $@;
			die;
		}
	}
}

sub checkstatebased {
	#check if Ships died
	my $game=shift;
	my $lanestring;
	my @triggers;
	for my $lane (1..5){
		if ($gamedata->{lane}{1}{$lane}>0 and $gamedata->{objects}{ $gamedata->{lane}{1}{$lane} }{"Health"} <= 0){
			my $died=$gamedata->{objects}{ $gamedata->{lane}{1}{$lane} };
			
			$died->{"zone"} = "graveyard";
			$gamedata->{lane}{1}{$lane} = 0;
			$lanestring.="1:$lane:0;";
			push (@triggers, ["died", $died]);
			
		}
		if ($gamedata->{lane}{2}{$lane}>0 and $gamedata->{objects}{ $gamedata->{lane}{2}{$lane} }{"Health"} <= 0){
			my $died= $gamedata->{objects}{ $gamedata->{lane}{2}{$lane} };
			
			$died->{"zone"} = "graveyard";
			$gamedata->{lane}{2}{$lane} = 0;
			$lanestring.="2:$lane:0;";
			push (@triggers, ["died", $died]);
			
		}
	}
	if ($lanestring) {
		$dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, `lane`) VALUES(?, ?)", undef, (0, $lanestring) );
   
	}
	foreach my $triggers (@triggers){
		checktriggers($triggers->[0], $triggers->[1]);
	}
	my $z=0;
	#debuglog("Checking static abilities");
	while ($z < $gamedata->{objectnumber}){
		unless ($gamedata->{objects}{$z} and $gamedata->{objects}{$z}{zone}) {
				$z++;
				next;
		};
		foreach my $static (@{$gamedata->{objects}{$z}{static}}) {
			#check if this ability should be active
			#debuglog("Checking this static ability of $z.");
			if ($allstatic->{$static}{"target"} eq "self"){
				#debuglog("This is a self static");
				if (checktarget($allstatic->{$static}{conditional}, $z, $gamedata->{objects}{$z}{owner} )) {
					#debuglog("We should be under this effect");
					#we should be under effect, lets check if we already are
					if ($gamedata->{objects}{$z}{undereffect}{"$z - $static"}){
						next;
					}else {
						$gamedata->{objects}{$z}{undereffect}{"$z - $static"}= 1;
						my $effect = $allstatic->{$static}{effect};
						
						applyeffects( { effecttype=> $alleffects->{$effect}{effecttype}, 
													effecttarget => $alleffects->{$effect}{effecttarget},
													effectmod1 => $alleffects->{$effect}{effectmod1}, 
													target => [$z],
													effectcontroller => $gamedata->{objects}{$z}{owner},
													} );
					}
				}else {
					#debuglog("We should not be under this effect");
					if ($gamedata->{objects}{$z}{undereffect}{"$z - $static"}){
						debuglog("Removing effect");
						delete $gamedata->{objects}{$z}{undereffect}{"$z - $static"};
						my $effect = $allstatic->{$static}{effect};
						removeeffect($alleffects->{$effect}{effecttype}, $alleffects->{$effect}{effecttarget}, $alleffects->{$effect}{effectmod1},  [$z], $gamedata->{objects}{$z}{owner});
						next;
					}else {
					}
				}
			}
		}
		
		$z++;
	}
	
	
	checkendgame();
	if (scalar @triggers > 0 ){ 
		checkstatebased();
	}
}


sub checktriggers { 
	#the type of trigger that occured
	my $type=shift;
	#The object if any that caused the trigger to happen. such as the Ship that entered play. undef for triggers caused by non-cards such
	#as moving on the wheel.
	my $triggerobject=shift;
	
	our $weare = 0;
	our $opp = 0;
	
	#this won't work if things trigger on opponent's turn... 
	if ($gamedata->{turn} == 1 ){
		$weare=1;
		$opp=2;
	}else {
		$weare=2;
		$opp=1;
	}
	my $z=0;
	while ($z < $gamedata->{objectnumber}){
		unless ($gamedata->{objects}{$z} and $gamedata->{objects}{$z}{zone}) {
				$z++;
				next;
		};
		
		if (@{$gamedata->{objects}{$z}{triggers}} > 0){
			foreach my $trigger (@{$gamedata->{objects}{$z}{triggers}}){
					#does this trigger trigger?
					if ($alltriggers->{$trigger}{type} ne $type or $alltriggers->{$trigger}{zone} ne $gamedata->{objects}{$z}{zone}){
						next;
					}
					
					checktriggersinner ( $gamedata->{objects}{$z}, $trigger, $triggerobject, $type, $weare);
				}
		}
		$z++;
	}
	
		
		
	if ($gamedata->{forceplay}){
		my $string = to_json($gamedata->{forceplay}[0]);
		$dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, `forcedaction`) VALUES(?, ? )", undef, ($gamedata->{players}{$weare}{playerid},  $string));
		if ($gamedata->{forceplay}[0]{revealtargets} ){
			foreach my $target (@{$gamedata->{forceplay}[0]{targets}[0]{raw}}){
				
				my $objectstring = "$target:".to_json($gamedata->{objects}{ $target});
				$dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, `object`) VALUES(?, ? )", undef, ($gamedata->{players}{$weare}{playerid},  $objectstring ));
			
			}
		}
	}
	foreach my $lane (1..5) {
		if ($gamedata->{lane}{$weare}{$lane} > 0 ){
			if ($gamedata->{objects}{$gamedata->{lane}{$weare}{$lane}}{newtriggers}){
				my $object = $gamedata->{objects}{ $gamedata->{lane}{$weare}{$lane} };
				if (!$object->{triggers}){
					$object->{triggers}=[];
				}
				push (@{$object->{triggers}}, @{$object->{newtriggers}});
				delete $object->{newtriggers};
				
				
				
				
			}
		}
	}
	
	
}

sub checktriggersinner {
	my $self = shift;
	my $object = $self->{id};
	my $trigger = shift;
	my $triggerobject = shift;
	my $type = shift;
	my $weare = shift;
	my $opp = 2;
	if ($weare == 2){
		$opp = 1;
	}
	#my $self = $gamedata->{objects}{$object};
					my $target = {};
					if ($triggerobject){
						
						$target=$triggerobject;
						#$target= $gamedata->{objects}{$triggerobject};
					}
					#Check if $target matches or $self
					if (!triggercompare($self, $target, $alltriggers->{$trigger}{trigger1}, $alltriggers->{$trigger}{compare1},$alltriggers->{$trigger}{target1})){
						
						return;
					}
					if (!triggercompare($self, $target, $alltriggers->{$trigger}{trigger2}, $alltriggers->{$trigger}{compare2},$alltriggers->{$trigger}{target2})){
						
						return;
					}
					if (!triggercompare($self, $target, $alltriggers->{$trigger}{trigger3}, $alltriggers->{$trigger}{compare3},$alltriggers->{$trigger}{target3})){
						
						return;
					}
					#trigger does in fact trigger
					
					
					my @targets;
					if ($alltriggers->{$trigger}{targettype} eq "allcards"){
						debuglog("this is an allcards trigger, checking all cards for validity");
						my ($targets, $totalvalidtargets) = findtargetsallzones($weare, $alltriggers->{$trigger}{targetindex});
						
						if ($totalvalidtargets == 0 ){
							debuglog("no targets for this trigger");
							
							return;
						}
						if ( !$gamedata->{forceplay} ) {
							$gamedata->{forceplay}=[];
						}
						push (@{$gamedata->{forceplay}}, {trigger => $trigger, revealtargets => 1, targets=>[{'text' => $alltargets->{$target}{text},
							l => [],
							o => [],
							
							raw => $targets }] } );
							
					
					}elsif ($alltriggers->{$trigger}{targettype} eq "self"){						
						push @targets, $object;
						applyeffects( { effecttype => $alltriggers->{$trigger}{effecttype}, 
												effecttarget => $alltriggers->{$trigger}{effecttarget},
												effectmod1 => $alltriggers->{$trigger}{effectmod1}, 
												target => \@targets,
												effectcontroller => $self->{owner} });
					}	elsif  ($alltriggers->{$trigger}{targettype} eq "single") {
						debuglog("player choice trigger");
						my ($lane, $olane, $totalvalidtargets)  = findtargets($weare, $alltriggers->{$trigger}{targetindex}); 
						foreach my $target ( @{$lane}){
							push @targets, $gamedata->{lane}{$weare}{$target};
						}
						foreach my $target ( @{$olane}){
							push @targets, $gamedata->{lane}{$opp}{$target};
						}
						
						if ($totalvalidtargets == 0 ){
							return;
						}
						
							
						if ( !$gamedata->{forceplay} ) {
							$gamedata->{forceplay}=[];
						}
						push (@{$gamedata->{forceplay}}, {trigger => $trigger, targets=>[{'text' => $alltargets->{$alltriggers->{$trigger}{targetindex}}{text},
							l => $lane,
							o => $olane }] } );
						
						
					}elsif ($alltriggers->{$trigger}{targettype} eq "cardinhand"){
						 my @raw;
						my $totalvalidtargets= 0;
						foreach my $card (@{$gamedata->{players}{$weare}{hand}} ){
							if (checktarget($alltriggers->{$trigger}{targetindex}, $card, $weare)){
								push (@raw, $card);
								$totalvalidtargets ++;
							}
						}
						
						if ($totalvalidtargets == 0 ) {
							return;
						}
						if ( !$gamedata->{forceplay} ) {
							$gamedata->{forceplay}=[];
						}
						push (@{$gamedata->{forceplay}}, {trigger => $trigger, targets=>[{'text' => $alltargets->{$target}{text},
							l => [],
							o => [],
							raw => \@raw }] } );
						
						 
					} elsif ($alltriggers->{$trigger}{targettype} eq "all"){
						#need to check all possible targets;
						debuglog("all type trigger");
						my ($lane, $olane, $totalvalidtargets)  = findtargets($weare, $alltriggers->{$trigger}{targetindex}); 
						foreach my $target ( @{$lane}){
							push @targets, $gamedata->{lane}{$weare}{$target};
						}
						foreach my $target ( @{$olane}){
							push @targets, $gamedata->{lane}{$opp}{$target};
						}
						
						if ($totalvalidtargets == 0 ){
							return;
						}
						foreach my $target (@targets) {
							
							if ($alltriggers->{$trigger}{effecttype} eq "neweffect")
							{
								debuglog("new effect type");
								my @effects = split (/,/, $alltriggers->{$trigger}{effectindexes});
								foreach my $effect (@effects) {
									applyeffects( {
										effecttype => $alleffects->{$effect}{effecttype}, 
										effecttarget => $alleffects->{$effect}{effecttarget},
										effectmod1 => $alleffects->{$effect}{effectmod1}, 
										target => [$target], 
										effectcontroller => $self->{owner}
										} );
									debuglog("applying effect! $effect -  $alleffects->{$effect}{effecttype}, $alleffects->{$effect}{effecttarget},$alleffects->{$effect}{effectmod1}, [$target], $weare ");
								}
								
								
								
							}else {
								
								applyeffects( {
									effecttype => $alltriggers->{$trigger}{effecttype}, 
									effecttarget => $alltriggers->{$trigger}{effecttarget},
									effectmod1 => $alltriggers->{$trigger}{effectmod1},
									target => [$target],
									effectcontroller => $self->{owner}
									 });
							}
						}
						
					}elsif ($triggerobject) {
						push @targets, $object;
						push @targets, $triggerobject->{id};
						applyeffects( {
							effecttype=> $alltriggers->{$trigger}{effecttype},
							effecttarget=> $alltriggers->{$trigger}{effecttarget},
							effectmod1=> $alltriggers->{$trigger}{effectmod1},
							target => \@targets,
							effectcontroller => $self->{owner},
							 
							});
						
					}else {
						push @targets, $object;
						applyeffects({
							effecttype => $alltriggers->{$trigger}{effecttype},
							effecttarge => $alltriggers->{$trigger}{effecttarget},
							effectmod1 => $alltriggers->{$trigger}{effectmod1}, 
							target => \@targets,
							effectcontroller =>  $self->{owner},
							});
						
					}
					
					
					
						my $message = $alltriggers->{$trigger}{log};
						$message=~ s/\%player\%/$gamedata->{players}{$weare}{name}/;
						
						$message=~ s/\%name\%/<link=$self->{CardId}><color=#000000>$self->{Name}<\/color><\/link>/;
						logmessage($message);
						
						my $controller = $gamedata->{objects}{$object}{owner};
						
						if ($alltriggers->{$trigger}{oneshot})
						{
							for( my $i=0; $i<=@{$gamedata->{objects}{$object}{triggers}}; $i++){
									if ($gamedata->{objects}{$object}{triggers}[$i] == $trigger){
										splice @{ $gamedata->{objects}{$object}{triggers} }, $i, 1;
										debuglog("removing this one shot trigger");
										#last;
									}
							}
							
						}
						
}

sub applyeffects {
	my $data = shift;
	my $effecttype = $data->{effecttype};
	my $effecttarget = $data->{effecttarget};
	my $effectmod1= $data->{effectmod1};
	my $targets = $data->{target};
	my $targetcontroller= ($data->{targetcontroller} or 0);
	my $effectcontroller = $data->{effectcontroller};
	my $targetindex = ($data->{targetindex} or 0);
	my $variables = $data->{variables};
	
	if ($effecttarget =~/target(\d+)/){
		$targetindex= $1;
	}
	debuglog("targets: ".Dumper($targets));
	if (defined $targets->[$targetindex]) {
		$targetcontroller = $gamedata->{objects}{$targets->[$targetindex]}{owner};
	}
	
	debuglog("applying: $effecttype to $effecttarget with mod of $effectmod1 . $effectcontroller, $targetcontroller.");
	
	
	my $opp=1;
	if ($effectcontroller == 1 ){
		$opp=2;
	}
	if ($effecttype eq "drawspecific"){ 
		#push(@{$gamedata->{players}{$weare }{hand}}, pop @{$gamedata->{"deck$weare"}});
		if ($gamedata->{objects}{$targets->[$targetindex]}{owner} eq $effectcontroller){
			if ($gamedata->{objects}{$targets->[$targetindex]}{zone} eq "deck"){
				for	(my $i=0; $i<@{$gamedata->{"deck$effectcontroller"}}; $i++){
					if ($gamedata->{"deck$effectcontroller"}[$i] == $targets->[$targetindex] ){
						push (@{$gamedata->{players}{$effectcontroller }{hand}},    splice(@{$gamedata->{"deck$$effectcontroller"}}, $i, 1));
						last;
					}
				}
			}elsif ($gamedata->{objects}{$targets->[$targetindex]}{zone} eq "discard" ) {
				for	(my $i=0; $i<@{$gamedata->{players}{$effectcontroller}{discard}}; $i++){
					if ($gamedata->{players}{$effectcontroller}{discard}[$i] == $targets->[$targetindex] ){
						push (@{$gamedata->{players}{$effectcontroller }{hand}},    splice(@{$gamedata->{players}{$effectcontroller}{discard}}, $i, 1));
						last;
					}
				}
			}
		}else {
			debuglog("We're not the owner of the target. $targets->[$targetindex]");
			if ($gamedata->{objects}{$targets->[$targetindex]}{zone} eq "deck"){
				for	(my $i=0; $i<@{$gamedata->{"deck$targetcontroller"}}; $i++){
					if ($gamedata->{"deck$targetcontroller"}[$i] == $targets->[$targetindex] ){
						push (@{$gamedata->{players}{$effectcontroller }{hand}},    splice(@{$gamedata->{"deck$targetcontroller"}}, $i, 1));
						last;
					}
				}
			}elsif ($gamedata->{objects}{$targets->[$targetindex]}{zone} eq "discard" ) {
				for	(my $i=0; $i<@{$gamedata->{players}{$targetcontroller}{discard}}; $i++){
					if ($gamedata->{players}{$targetcontroller}{discard}[$i] == $targets->[$targetindex] ){
						push (@{$gamedata->{players}{$effectcontroller }{hand}},    splice(@{$gamedata->{players}{$targetcontroller}{discard}}, $i, 1));
						last;
					}
				}
			}elsif ($gamedata->{objects}{$targets->[$targetindex]}{zone} eq "hand" ) {
				debuglog("it's in our opponent's hand");
				for	(my $i=0; $i<@{$gamedata->{players}{$targetcontroller}{hand}}; $i++){
					debuglog("$i: $gamedata->{players}{$targetcontroller}{hand}[$i]  - $targets->[$targetindex]");
					if ($gamedata->{players}{$targetcontroller}{hand}[$i] == $targets->[$targetindex] ){
						push (@{$gamedata->{players}{$effectcontroller }{hand}},    splice(@{$gamedata->{players}{$targetcontroller}{hand}}, $i, 1));
						$dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, `draws`) VALUES(?, ?)", undef, ($gamedata->{players}{$targetcontroller}{playerid}, -$gamedata->{players}{$effectcontroller }{hand}[-1] ));
			
						last;
					}
				}
			}
			$gamedata->{objects}{$targets->[$targetindex]}{owner}=$effectcontroller;
		}
			my $card = $gamedata->{players}{$effectcontroller }{hand}[-1];
			$gamedata->{objects}{$card}{zone}="hand";
			my $objectstring = "$card:".to_json($gamedata->{objects}{$card});
		   $dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, `object`) VALUES(?, ? )", undef, ($gamedata->{players}{$effectcontroller}{playerid}, $objectstring ));
	
			$dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, `draws`) VALUES(?, ?)", undef, ($gamedata->{players}{$effectcontroller}{playerid}, $gamedata->{players}{$effectcontroller }{hand}[-1] ));
			
	}
	if ($effecttype eq "Destroy"){
		if ($effecttarget eq "target$targetindex"){
			$gamedata->{objects}{$targets->[$targetindex]}{Health}= 0;
		}
	}
	if ($effecttype eq "Negate"){
		if ($effecttarget eq "self" or $effecttarget eq "target$targetindex"){
			my $keyword;
			
			$gamedata->{objects}{$targets->[$targetindex]}{"keyword"}{$effectmod1}=-1;
			
			my $objectstring = "$targets->[$targetindex]:".to_json($gamedata->{objects}{ $targets->[$targetindex]});
			$dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, `object`) VALUES(?, ? )", undef, (0,  $objectstring ));
						
		}
	}
	if ($effecttype eq "keyword"){
		if ($effecttarget eq "self" or $effecttarget eq "target$targetindex"){
			my $keyword;
			my $amount;
			if ($effectmod1=~/(.*?) (\d+)/i){
				$keyword = $1;
				$amount = $2;
			}else {
				$keyword = $effectmod1;
				$amount = 1;
			}
			#less than 0 prevents us from gaining keyword
			if (checkkeyword($keyword, $targets->[$targetindex]) >= 0 ) {
				$gamedata->{objects}{$targets->[$targetindex]}{"keyword"}{$keyword}+=$amount;
			}
			if ($gamedata->{objects}{$targets->[$targetindex]}{zone} eq "play"){
				my $objectstring = "$targets->[$targetindex]:".to_json($gamedata->{objects}{ $targets->[$targetindex]});
				$dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, `object`) VALUES(?, ? )", undef, (0,  $objectstring ));
			}
		}
	}
	if ($effecttype eq "Silence"){
		if ($effecttarget eq "self" or $effecttarget eq "target$targetindex"){
			foreach my $keyword (keys %{$gamedata->{objects}{$targets->[$targetindex] }{"keyword"}}) { 
				next unless ($keyword);
				$gamedata->{objects}{$targets->[$targetindex] }{"keyword"}{$keyword}=-1;
			}
			my $cardid = $gamedata->{objects}{$targets->[$targetindex] }{"CardId"};
			$gamedata->{objects}{$targets->[$targetindex] }{Attack} = $allcards->{$cardid}{Attack};
			$gamedata->{objects}{$targets->[$targetindex] }{maxhealth} = $allcards->{$cardid}{Health};
			if ($gamedata->{objects}{$targets->[$targetindex] }{Health} > $allcards->{$cardid}{Health}){
				$gamedata->{objects}{$targets->[$targetindex] }{Health} = $allcards->{$cardid}{Health};
			}
			$gamedata->{objects}{$targets->[$targetindex] }{triggers} = [];
			$gamedata->{objects}{$targets->[$targetindex] }{activated} = "";
			$gamedata->{objects}{$targets->[$targetindex] }{Text} = "";
			my $objectstring = "$targets->[$targetindex]:".to_json($gamedata->{objects}{ $targets->[$targetindex]});
			$dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, `object`) VALUES(?, ? )", undef, (0,  $objectstring ));
						
		}
	}
	
	if ($effecttype eq "levelinhand") {
		if ($gamedata->{"objects"}{$targets->[$targetindex]}{"levelsto"} == 0 ){
			return;
		}
		my $new= createobject( $gamedata->{"objects"}{$targets->[$targetindex]}{"levelsto"}, $targetcontroller, 0);
		
		$gamedata->{"objects"}{$new}{"zone"}="hand";
		$gamedata->{"objects"}{$targets->[$targetindex] }{"zone"}="graveyard";
		push @{$gamedata->{players}{$targetcontroller}{hand}}, $new;
		for (my $i=0; $i<=@{$gamedata->{players}{$targetcontroller }{hand}}; $i++){
            if ($gamedata->{players}{$targetcontroller }{hand}[$i] == $targets->[$targetindex]){
                splice(@{$gamedata->{players}{$targetcontroller }{hand}}, $i, 1);
                last;
            }
        }
		$dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, `draws`) VALUES(?, ?)", undef, ($gamedata->{players}{$targetcontroller}{playerid}, -$targets->[$targetindex] ));
		$dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, `draws`) VALUES(?, ?)", undef, ($gamedata->{players}{$targetcontroller}{playerid}, $new ));
		 my $objectstring = "$new:".to_json($ksgameshared::gamedata->{objects}{ $new });
		 $ksgameshared::dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, `object`) VALUES(?, ? )", undef, (0, $objectstring ));
            
		
		
	}
	if ($effecttype eq "Discard") {
		
		$gamedata->{objects}{$targets->[$targetindex]}{"zone"}="discard";
		my $player = $gamedata->{objects}{ $targets->[$targetindex] }{"owner"};
		
		for (my $i=0; $i<@{$gamedata->{players}{$player }{hand}}; $i++){
            if ($gamedata->{players}{$player }{hand}[$i] == $targets->[$targetindex]){
                splice(@{$gamedata->{players}{$player }{hand}}, $i, 1);
                last;
            }
        }
        push @{$gamedata->{players}{$player}{discard}}, $targets->[$targetindex];
        
		$dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, `draws`) VALUES(?, ?)", undef, ($gamedata->{players}{$player}{playerid}, -$targets->[$targetindex] ));

	}
	if ($effecttype eq "level") {
		if ($gamedata->{"objects"}{ $targets->[$targetindex] }{"levelsto"} == 0 ){
			return;
		}
		my $new= createobject( $gamedata->{"objects"}{$targets->[$targetindex]}{"levelsto"}, $targetcontroller, 0);
		
		$gamedata->{"objects"}{$new}{"zone"}="discard";
		push @{$gamedata->{players}{$effectcontroller}{discard}}, $new;
		$gamedata->{"objects"}{$targets->[$targetindex]}{zone}="graveyard";
		for (my $i=0; $i<@{$gamedata->{players}{$effectcontroller }{hand}}; $i++){
            if ($gamedata->{players}{$effectcontroller }{hand}[$i] == $targets->[$targetindex]){
                splice(@{$gamedata->{players}{$effectcontroller }{hand}}, $i, 1);
                last;
            }
        }
         my $objectstring = "$new:".to_json($ksgameshared::gamedata->{objects}{ $new });
		 $ksgameshared::dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, `object`) VALUES(?, ? )", undef, ($gamedata->{players}{$effectcontroller}{playerid}, $objectstring ));
        
		$dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, `draws`) VALUES(?, ?)", undef, ($gamedata->{players}{$effectcontroller}{playerid}, -$targets->[$targetindex] ));
	}
	if ($effecttype eq "heal") {
		if ($effecttarget eq "controller"){
			debuglog("healing our controller - $targetcontroller - $effectcontroller - $gamedata->{objects}{$targets->[$targetindex]}{owner}");
			$gamedata->{players}{ $effectcontroller }{life}+=$effectmod1;
			checktriggers("healed",  $gamedata->{players}{$effectcontroller } );
		}
		if ($effecttarget eq "opponent"){
			my $opp = 1;
			if ($effectcontroller == 1){
				$opp=2;
			}
			$gamedata->{players}{$opp}{life}+=$effectmod1;
			checktriggers("healed",  $gamedata->{players}{$opp} );
		}
		my $healthstring="1:$ksgameshared::gamedata->{players}{1}{life};2:$ksgameshared::gamedata->{players}{2}{life}";
		$ksgameshared::dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, life) VALUES(?, ? )", undef, (0, $healthstring ) );
   
		if ($effecttarget eq "target$targetindex"){
			$ksgameshared::gamedata->{objects}{ $targets->[$targetindex] }{Health}+= $effectmod1;
			if ($ksgameshared::gamedata->{objects}{ $targets->[$targetindex] }{Health} > $ksgameshared::gamedata->{objects}{ $targets->[$targetindex] }{maxhealth}){
				$ksgameshared::gamedata->{objects}{ $targets->[$targetindex] }{Health} = $ksgameshared::gamedata->{objects}{ $targets->[$targetindex] }{maxhealth};
			}
		}
		my $objectstring = "$targets->[$targetindex]:".to_json($gamedata->{objects}{$targets->[$targetindex]});
		$dbh->do("INSERT INTO `GameMessages_$game` (`playerid`,  `object`) VALUES(?, ? )", undef, (0,  $objectstring ));
							
		
	}
	if ($effecttype eq "stats"){
		
		if ($effecttarget eq "self" or $effecttarget eq "target$targetindex"){
			statadjust($targets->[$targetindex], $effectmod1);
		}
		if ($effecttarget eq "trigger"){
			
			statadjust($targets->[1], $effectmod1);
		}
							
	}
	if ($effecttype eq "draw"){
		if ($effecttarget eq "controller"){
			drawcard($effectcontroller, $effectmod1);
		}
		if ($effecttarget eq "opponent"){
			my $opp = 1;
			if ($effectcontroller == 1){
				$opp=2;
			}
			drawcard($opp, $effectmod1);
		}
	}
	
	if ($effecttype eq "move"){
		if ($effecttarget eq "opposingShip"){
			my $lane = $gamedata->{objects}{$targets->[$targetindex]}{lane};
			if ($gamedata->{lane}{$opp}{$lane}>0 and $lane >0){
				if ($effectmod1 eq "randomenemylane"){
					my $target = randomemptylane($opp);
					if ($target>0){
						$gamedata->{lane}{$opp}{$target}=$gamedata->{lane}{$opp}{$lane};
						$gamedata->{lane}{$opp}{$lane} = 0;
						#$gameshared::dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, `lane`) VALUES(?, ?)", undef, (0, "$opp:$lane:0;$opp:$target:$gamedata->{lane}{$opp}{$target}"));
						my $objectstring = "$gamedata->{lane}{$opp}{$lane}:".to_json($gamedata->{objects}{$gamedata->{lane}{$opp}{$lane}});
						$dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, `lane`, `object`) VALUES(?, ?, ? )", undef, (0, "$opp:$lane:0;$opp:$target:$gamedata->{lane}{$opp}{$target}", $objectstring ));
								
					}
				}
			}
		}
							
	}
	if ($effecttype eq "Spawn"){ 
		if ($effecttarget eq "AllUnopposedEnemies"){
			foreach my $lane (1..5){
				if ($gamedata->{lane}{$opp}{$lane} > 0 and $gamedata->{lane}{$effectcontroller}{$lane} == 0){
					my $object =  createobject($effectmod1, $effectcontroller, $lane );
					$gamedata->{lane}{$effectcontroller}{$lane}=$object;
					$gamedata->{objects}{$object}{ss}=1;
					my $objectstring = "$object:".to_json($gamedata->{objects}{$object});
					$dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, `lane`, `object`) VALUES(?, ?, ? )", undef, (0, "$effectcontroller:$lane:$object", $objectstring ));
			
				}
			}
		}
		if ($effecttarget eq "randomemptylane"){
			#find all empty lanes so we can pick one at random
			debuglog("we are $effectcontroller and spawning something( $effectmod1 ) in a random lane. $gamedata->{objects}{$targets->[0]}{owner}");
			my $targetlane = randomemptylane( $effectcontroller  );
			if ( $targetlane > 0){
				my $object = createobject($effectmod1, $effectcontroller, $targetlane );
				$gamedata->{lane}{$effectcontroller}{$targetlane}=$object;
				$gamedata->{objects}{$object}{ss}=1;
				my $objectstring = "$object:".to_json($gamedata->{objects}{$object});
				$dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, `lane`, `object`) VALUES(?, ?, ? )", undef, (0, "$effectcontroller:$targetlane:$object", $objectstring ));
			}
			
			
		}
	}
	if ($effecttype eq "Damage"){
		if ($effectmod1 =~/(\d+)-(\d+)/){
			my $result=int(rand($2-$1))+$1;
			$effectmod1=$result;
		}
		if ($effecttarget eq "AllEnemyShips"){
			foreach my $lane (1..5){
				if ($gamedata->{lane}{$opp}{$lane}>0){
					applydamage($gamedata->{lane}{$opp}{$lane}, $effectmod1, 2);
					 my $objectstring = "$ksgameshared::gamedata->{lane}{$opp}{$lane}:".to_json($ksgameshared::gamedata->{objects}{ $ksgameshared::gamedata->{lane}{$opp}{$lane} });
					$ksgameshared::dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, `object`) VALUES(?, ? )", undef, (0, $objectstring ));
            
				}	
			}
		}
		if ($effecttarget eq "self" or $effecttarget eq "target$targetindex"){
			applydamage($targets->[$targetindex], $effectmod1, 2);
		}
		if ($effecttarget eq "opponent"){
			
			$gamedata->{players}{$opp}{life} -= $effectmod1;
		}
		if ($effecttarget eq "controller"){
			$gamedata->{players}{$effectcontroller}{life} -= $effectmod1;
		}
		 my $healthstring="1:$ksgameshared::gamedata->{players}{1}{life};2:$ksgameshared::gamedata->{players}{2}{life}";
		$ksgameshared::dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, life) VALUES(?, ? )", undef, (0, $healthstring ) );
    
		
	}
	if ($effecttype eq "AddTrigger"){
		
		if ( defined $gamedata->{objects}{$targets->[$targetindex]}{newtriggers} ){
			push(@{$gamedata->{objects}{$targets->[$targetindex]}{newtriggers}}, $effectmod1);
		}else {
			$gamedata->{objects}{$targets->[$targetindex]}{newtriggers}=[];
			push(@{$gamedata->{objects}{$targets->[$targetindex]}{newtriggers}}, $effectmod1);
		}
		
	}
	
}
sub shufflediscardintodeck {
	my $weare=shift;
	my @stays;
	my @changedobjects;
	foreach my $card (@{$ksgameshared::gamedata->{players}{$weare }{discard}}){
		if ($gamedata->{objects}{$card}{level}<= $ksgameshared::gamedata->{players}{$weare}{level} )  {
			$ksgameshared::gamedata->{objects}{$card}{zone}="deck";
			push @{$ksgameshared::gamedata->{"deck$weare"}}, $card;
			push (@changedobjects, $card);
		}else {
			push @stays, $card;
		}
    }
    @changedobjects= shuffle(@changedobjects);
    
	foreach my $new (@changedobjects){
		my $objectstring = "$new:".to_json($ksgameshared::gamedata->{objects}{ $new });
		$ksgameshared::dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, `object`) VALUES(?, ? )", undef, ($gamedata->{players}{$weare}{playerid}, $objectstring ));
    }
    @{$ksgameshared::gamedata->{"deck$weare"}} =  shuffle(@{$ksgameshared::gamedata->{"deck$weare"}});
        
    $ksgameshared::gamedata->{players}{$weare}{discard}=\@stays;
        
}
sub removeeffect {
	my $effecttype = shift;
	my $effecttarget = shift;
	my $effectmod1=shift;
	my $targets = shift;
	my $weare = shift;
	my $opp=1;
	if ($weare == 1 ){
		$opp=2;
	}
	debuglog("REMOVING! $effecttype - $effecttarget - $effectmod1 ");
	if ($effecttype eq "keyword") {
		debuglog("Removing keyword!");
		my $keyword;
		my $amount;
		if ($effectmod1=~/(.*?) (\d+)/i){
			$keyword = $1;
			$amount = $2;
		}else {
			$keyword = $effectmod1;
			$amount = 1;
		}
		$amount = 0-$amount;
		if (checkkeyword($keyword, $targets->[0]) >= 0 ) {
				$gamedata->{objects}{$targets->[0]}{"keyword"}{$keyword}+=$amount;
		}
		my $objectstring = "$targets->[0]:".to_json($gamedata->{objects}{ $targets->[0]});
		$dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, `object`) VALUES(?, ? )", undef, (0,  $objectstring ));
		debuglog("REMOVED KEYWORD $keyword by $amount\n\n");
			
	}
	if ($effecttype eq "stats"){
		
		if ($effecttarget eq "self" or $effecttarget eq "target0"){
			statadjust($targets->[0], $effectmod1);
		}
		if ($effecttarget eq "trigger"){
			
			statadjust($targets->[1], $effectmod1);
		}
							
	}
	
	

}



sub applydamage {
	my $object = shift;
	my $damage=shift;
	
	if ($damage <=0){
		return 0;
	}
	$gamedata->{objects}{$object}{Health}-= $damage;
	my $objectstring = "$object:".to_json($gamedata->{objects}{ $object });
        $dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, `object`) VALUES(?, ? )", undef, (0, $objectstring ));
           
	 
}



sub statadjust {
	my $object = shift;
	my $stats = shift;
	my $reverse = shift;
	my @stats = split("/", $stats);
	if (ref $object eq "HASH"){
		debuglog("Is a hash, making a id");
		$object = $object->{id};
	}
	
	debuglog("stat adjust for object $object : $stats ".ref $object);		
	my $mod = substr($stats[0], 0, 1);
	
	my $amount = substr($stats[0], 1);
	if ($mod eq "+"){
		$gamedata->{objects}{$object}{Attack} += $amount;
	}elsif ($mod eq "-"){
		$gamedata->{objects}{$object}{Attack} -= $amount;
	}elsif ($mod eq "="){
		$gamedata->{objects}{$object}{Attack} = $amount;
	}else {
		$gamedata->{objects}{$object}{Attack} += $amount;
	}
								
 	$mod = substr($stats[1], 0, 1);
	
	$amount = substr($stats[1], 1);
	if ($mod eq "+"){
		$gamedata->{objects}{$object}{Health} += $amount;
		$gamedata->{objects}{$object}{maxhealth} += $amount;
	}elsif ($mod eq "="){
		$gamedata->{objects}{$object}{Health} = $amount;
		$gamedata->{objects}{$object}{maxhealth} = $amount;
	}elsif ($mod eq "-"){
		$gamedata->{objects}{$object}{Health} -= $amount;
		$gamedata->{objects}{$object}{maxhealth} -= $amount;
	}
	
	
	my $objectstring = "$object:".to_json($gamedata->{objects}{$object});
	$dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, `object`) VALUES(?, ? )", undef, (0, $objectstring ));
														
	 
}

sub discard {
    my $weare=shift;
	my $number = (shift or 0);
	warn "discard called";
	foreach my $card (@{$gamedata->{players}{$weare }{hand}} ) {
        warn "checking if we should discard $card<BR>";
        
        if (!$number or $number == $card){
            warn "discarding cards!";
            
            $gamedata->{objects}{$card}{zone}="discard";
            push (@{$gamedata->{players}{ $weare }{discard}}, $card);
            my $objectstring = "$card:".to_json($gamedata->{objects}{$card});
            $dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, `object`) VALUES(?, ? )", undef, ($gamedata->{players}{$weare}{playerid}, $objectstring ));
	
            $dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, `draws`) VALUES(?, ?)", undef, ($gamedata->{players}{$weare}{playerid}, -$card ));
            
		}
	}
	if (!$number) {
        $gamedata->{players}{$weare}{hand}=[];
	}else {
        for (my $i=0; $i<=@{$gamedata->{players}{$weare }{hand}}; $i++){
            if ($gamedata->{players}{$weare }{hand}[$i] == $number){
                splice(@{$gamedata->{players}{$weare }{hand}}, $i, 1);
                last;
            }
        }
	}
		
}
sub drawcard {
	my $weare=shift;
	my $number = (shift or 1);
	
	while ($number >0){
		if (@{$gamedata->{"deck$weare"}}<= 0 ){
			shufflediscardintodeck($weare);
			logmessage("$gamedata->{players}{$weare}{name} shuffles their discard into deck. (no cards were in deck)");
		}
			push(@{$gamedata->{players}{$weare }{hand}}, pop @{$gamedata->{"deck$weare"}});
			my $card = $gamedata->{players}{$weare }{hand}[-1];
			$gamedata->{objects}{$card}{zone}="hand";
			my $objectstring = "$card:".to_json($gamedata->{objects}{$card});
		   $dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, `object`) VALUES(?, ? )", undef, ($gamedata->{players}{$weare}{playerid}, $objectstring ));
	
			$dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, `draws`) VALUES(?, ?)", undef, ($gamedata->{players}{$weare}{playerid}, $gamedata->{players}{$weare }{hand}[-1] ));
			
		
		$number --;
		
	}
}
sub randomemptylane {
	my $who=shift;
	my @lanes = findemptylanes($who);
	if (int @lanes > 0 ){
		return $lanes[ int rand(@lanes) ] ;
	}else {
		return 0;
	}
	
}

sub findemptylanes {
	my $who=shift;
	my @emptylanes;
	foreach my $i (1..5) {
		if ($gamedata->{lane}{$who}{$i}==0){
			push (@emptylanes, $i);
		}
	}
	return @emptylanes;
}


sub triggercompare {
	my $self =shift;
	my $target= shift;
	my $equation1 = shift;
	my $equationcomp = shift;
	my $equation2 = shift;
	
	my $var1="";
	my $var2="";
	if (!defined $self){
		return 0;
	}
	if (!defined($equationcomp) or length ($equationcomp) == 0 ) {
		
		return 1;
	}
	
	my @results = split(/\./, $equation1);
	#if ($equation1=~/^self.(.*?)$/){
		debuglog("equation1 = $equation1, @results");
	if ($results[0] eq "self"){
		if ($results[1] eq "controller"){
			debuglog("controller stat check $self->{owner} - @results");
			$var1=$gamedata->{players}{$self->{owner} }{$results[2] };
		}elsif ($results[1] eq "factioninhand"){
			my $number=0;
			foreach my $card ( @{$gamedata->{players}{$self->{owner}}{hand}}){
				if ($gamedata->{objects}{$card}{Faction} eq $results[2]){
					$number ++;
				}
			}
			$var1=$number;
		}elsif ($results[1] eq "keyword"){
			$var1=checkkeyword($results[2], $self->{id})
		}else {
			if (!defined $self->{$results[1]}){
				debuglog("Error, not defined in self!");
				
				return 0;
			}
			$var1=$self->{$results[1]};
		}
	}
	#if ($equation1=~/^target.(.*?)$/){
	if ($results[0] eq "target"){
		if (!$target){
			debuglog("target is undefined");
		}
		if ($results[1] eq "controller"){
			$var1=$gamedata->{players}{ $target->{owner} }{$results[2] };
		}elsif ($results[1] eq "keyword"){
			$var1 = checkkeyword($results[2], $target->{id});
		}else {
			if (!defined $target->{$results[1]}){
				debuglog("Error, not defined in target!");
				
				return 0;
			}
			$var1=$target->{$results[1]};
		}
	}
	#if ($equation1=~/^core.(.*?)$/){
	if ($results[0] eq "core"){
		$var1=$gamedata->{$results[1]};
	}
	
	
	if ($equation2=~/^target.(.*?)$/){
		$var2=$target->{$1};
	}
	
	if ($equation2=~/^self.(.*?)$/){
		$var2=$self->{$1};
	}
	if ($equation2=~/^core.(.*?)$/){
		$var2=$gamedata->{$1};
	}
	if ($equation2=~/^value.(.*?)$/){
		$var2=$1;
	}
	
	
	debuglog("$equation1, $equation2");
	debuglog("$var1 $equationcomp $var2 ? ");
	
	if ($equationcomp eq "="){
		if ($var1 == $var2 ) {
			return 1;
		}else {
			return 0;
		}
	}
	if ($equationcomp eq "eq"){
		if ($var1 eq $var2 ) {
			return 1;
		}else {
			return 0;
		}
	}
	
	if ($equationcomp eq "<"){
		if ($var1 < $var2 ) {
			return 1;
		}else {
			return 0;
		}
	}
	
	if ($equationcomp eq ">"){
		if ($var1 > $var2 ) {
			return 1;
		}else {
			return 0;
		}
	}
	if ($equationcomp eq "<="){
		if ($var1 <= $var2 ) {
			return 1;
		}else {
			return 0;
		}
	}
	
	if ($equationcomp eq ">="){
		if ($var1 >= $var2 ) {
			return 1;
		}else {
			return 0;
		}
	}
	if ($equationcomp eq "!="){
		debuglog("$var1 != $var2 ? ");
		if ($var1 != $var2 ) {
			return 1;
		}else {
			return 0;
		}
	}
}


sub savegame {
    my $game=shift;
    
    checkstatebased($game);
    
    my $data=Dumper($gamedata);
    $dbh->do("UPDATE `GameData` SET `data` = ? WHERE `gameid` = ?", undef, ($data, $game));

}
sub sendnewmessages{
    my $game=shift;
    my $response;
    my $startmessage= (param("startmessage") or param("lastmessage") );
    if ($startmessage){
        $response->{messages}=$dbh->selectall_arrayref("SELECT * from `GameMessages_$game` WHERE  `messageid` > ? AND (`playerid`= ? or `playerid` = 0) ORDER BY `messageid` ASC", {Slice =>{}}, ($startmessage, $player->{userId}));
    }else{
        $response->{messages}=$dbh->selectall_arrayref("SELECT * from `GameMessages_$game` WHERE `playerid` = ? or `playerid` = 0 ORDER BY `messageid` ASC", {Slice =>{}}, ($player->{userId}));
    }
    #print "Content-Type: Text/JSON\n\n";

	foreach my $row (@{$response->{messages}}){
		foreach my $col (keys %{$row}){
			if (!defined $row->{$col} or length($row->{$col}) == 0) {
				#print "$col -- $row->{$col}<BR>";
				delete($row->{$col});
			}
		}
		delete($row->{playerid});
	}
    return $response->{messages};
}

sub createobject {
	my $basecard=shift;
	my $owner = shift;
	my $lane =(shift or 0);
	unless ($allcards->{$basecard}){
		debuglog( "Card doesn't exists? $basecard");
	}
	my $card= {};
	foreach my $data (keys %{$allcards->{$basecard}} ) {
		$card->{$data} = $allcards->{$basecard}{$data};
	}
	$card->{triggers}=[];
	if ($card->{basetriggers}){	
		@{$card->{triggers}}=split(",", $card->{basetriggers});
	}
	$card->{static}= [];
	if ($card->{basestatic}){
		@{$card->{static}}=split(",", $card->{basestatic});
	}
	$card->{keyword}={};
	if ($card->{keywords}){
		my @keywords = split(",", $card->{keywords});
		foreach my $keyword (@keywords) {
			if ($keyword=~s/ (\d+)$//){
				$card->{keyword}{$keyword}=$1;
			}else {
				$card->{keyword}{$keyword}=1;
			}
		}
	}
	
	if (!defined $gamedata->{objects} ){
		$gamedata->{objects}={};
	}
	my $objectnumber = $gamedata->{objectnumber}+1;
	$card->{owner} = $owner;
	$card->{id}=$objectnumber;
	if ($lane > 0 ){
		$card->{zone} = "play";
	}
	$card->{lane}=$lane;
	$gamedata->{objectnumber}=$objectnumber;
	$gamedata->{objects}{$objectnumber} = $card;
	
	return $objectnumber;
	
	
}

sub checkkeyword {
	my $keyword = shift;
	my $object = shift;
	unless ($object){
		warn "NO OBJECT!";
	}
	if (defined ($gamedata->{objects}{ $object }{"keyword"}{$keyword}) and ($gamedata->{objects}{ $object }{"keyword"}{$keyword} > 0)){
		return $gamedata->{objects}{ $object }{"keyword"}{$keyword};
	}else {
		return 0;
	}
}

sub checkendgame {
	my $winner=0;
	if ($gamedata->{players}{1}{life} <=0 and $gamedata->{players}{1}{life} < $gamedata->{players}{2}{life}){
		#player 1 has lost
		$gamedata->{ended}=2;
		logmessage("$gamedata->{players}{1}{name} has lost the game!");
		$dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, `ended`) VALUES(?, ?)", undef, (0, 2));
		$winner=2;
    
	}
	if ($gamedata->{players}{2}{life} <=0 and $gamedata->{players}{2}{life} < $gamedata->{players}{1}{life}){
		#player2 has lost
		$gamedata->{ended}=1;
		logmessage("$gamedata->{players}{2}{name} has lost the game!");
		$dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, `ended`) VALUES(?, ?)", undef, (0, 1));
		$winner=1;
	}
	if ($winner){
		use LWP::UserAgent;
		use HTTP::Request;
	
		my $userAgent = LWP::UserAgent->new();
		my $request = HTTP::Request->new( POST => "https://kaelari.tech/ksplatform/endgame.cgi" );
		warn "ending game: &game=$game&winner=$winner";
		$request->content("password=ajdkhfaksjfhakdsaflkjhas&game=$game&winner=$winner");
		$request->content_type("application/x-www-form-urlencoded");
		my $response = $userAgent->request($request);
	}
}

sub checkcast {
	my $canplay="";
	my @canplay;
	my $weare=$gamedata->{turn};
	my $opp= 0;
	
	if ($weare == 1 ){
		$opp = 2;
	}else {
		$opp=1;
	}
        outer: foreach my $card (@{$gamedata->{players}{$gamedata->{turn} }{hand} }){
		if ($gamedata->{objects}{$card}{CardType} ne "Effect"){
			next;
		}
		
		if ( ($gamedata->{objects}{$card}{cost} > $gamedata->{players}{$gamedata->{turn}}{gold} ) and (checkkeyword("Free", $gamedata->{objects}{$card}) <=0 ) ){
			#we don't have enough actions!                
			next;
		}
		my %threshold;
		foreach my $type (split("",  $gamedata->{objects}{$card}{threshold} ) ) {
            	
			$threshold{$type}+=1;
		}
    
		foreach my $type (keys %threshold){
			if (!defined ($gamedata->{players}{ $gamedata->{turn} }{threshold}{$type}) ) {
				next outer;
			}
			if ($threshold{$type} > $gamedata->{players}{ $gamedata->{turn} }{threshold}{$type}){
				#we don't have threshold!
                    
				next outer;
			}
		}
		my $card2=$card;
                
		my $targets= [{
			}];
		my $lane;
		my $olane;
		
		foreach my $target (split (",",$gamedata->{objects}{$card}{targets} )){
			if (!$target){
				next;
			}
			my $totalvalidtargets=0;
			($lane, $olane, $totalvalidtargets) = findtargets ($weare, $target);
				
			if ($totalvalidtargets == 0){	
				next outer;
			}
			$targets = [ {
				'text' => $alltargets->{$target}{text},
				l => $lane,
				o => $olane,
			}];
                }
                $card2="$card:".to_json($targets);
		push (@canplay, $card2);
		
	}
        
        
        $canplay=join(";", @canplay);
        if (length ($canplay) == 0){
		$canplay="[]";
        }
        $dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, `handplayable`) VALUES(?, ?)", undef, ($player->{userId}, $canplay ));
	$gamedata->{hidden}{$gamedata->{turn}}{handplayable}=$canplay;
	 
}

sub findtargetsallzones {
	my $weare = shift;
	my $target = shift;
	my $opp = 1;
	if ($weare == 1) {
		$opp=2;
	}
	my $totalvalidtargets=0;
	my @targets;
	foreach my $card (keys %{$gamedata->{objects}}){
		if (defined $gamedata->{objects}{$card}{zone}){
			#debuglog("Checking $card ".Data::Dumper::Dumper($gamedata->{objects}{$card}));
		}
		if (checktarget($target, $card, $weare ) ){
				push (@targets, $card);
				$totalvalidtargets +=1;
			}
	}
	@targets = shuffle(@targets);
	return \@targets, $totalvalidtargets;
}
sub findtargets {
	my $weare = shift;
	my $target = shift;
	my $opp = 1;
	if ($weare == 1) {
		$opp=2;
	}
	my $totalvalidtargets=0;
	my @lane;
	my @olane;
		for my $lane (1..5) {
				if ($gamedata->{lane}{$weare}{$lane} == 0 ){
					next;
				}
				if (checktarget($target, $gamedata->{lane}{$weare}{$lane}, $weare ) ){
					push (@lane, $lane);
					$totalvalidtargets +=1;
				}
			}
			for my $lane (1..5) {
				if ($gamedata->{lane}{$opp}{$lane} == 0 ){
					next;
				}
				if (checktarget($target , $gamedata->{lane}{$opp}{$lane}, $weare ) ){
					push (@olane, $lane);
					$totalvalidtargets +=1;
				}
			}
	 return \@lane, \@olane, $totalvalidtargets;
}



#Takes 
#$target  (string alltargets index)
#$object  (Object in the lane if any)
#$weare  

sub checktarget {
	my $target = shift;
	my $object=shift;
	my $weare = shift;
	if (!$target) {
		return 1;
	}
	debuglog(" target='$target'");
	debuglog("$alltargets->{$target}{target1var}, $alltargets->{$target}{target1compare},$alltargets->{$target}{target1target} ");
	
	if (!triggercompare($gamedata->{objects}{$object}, undef, $alltargets->{$target}{target1var}, $alltargets->{$target}{target1compare},$alltargets->{$target}{target1target})){
		return 0;
	}
	if (!triggercompare($gamedata->{objects}{$object}, undef, $alltargets->{$target}{target2var}, $alltargets->{$target}{target2compare},$alltargets->{$target}{target2target})){
		return 0;
	}
	if (!triggercompare($gamedata->{objects}{$object}, undef, $alltargets->{$target}{target3var}, $alltargets->{$target}{target3compare},$alltargets->{$target}{target3target})){
		return 0;
	}
	return 1;
	
	
	
	 
}

sub checkplays {
    my $canplay="";
	my @canplay;
	my $weare = $gamedata->{turn};
	outer: foreach my $lane (1..5){
		if ($gamedata->{lane}{$weare}{$lane}>0){
			my $card = $gamedata->{lane}{$weare}{$lane};
			my $card2 = $card;
			if ($gamedata->{objects}{ $card }{activated}){
				debuglog("We found an activated ability to try to activate: $gamedata->{objects}{ $card }{activated}");
				debuglog("$allactivated->{ $gamedata->{objects}{ $card }{activated} }{targetindex}");
				if ($gamedata->{objects}{$card}{ss}>0 ){
					next outer;
				}
				if ($gamedata->{objects}{$card}{activatedthisturn}>0 ){
					next outer;
				}
				
				my $targets= [];
				foreach my $target ( split(",", $allactivated->{ $gamedata->{objects}{ $card }{activated} }{targetindex} ) ){
					debuglog("trying to find targets from $target target");
					
					my $lane;
					my $olane;
					if (!$target){
						next;
					}
					if ($alltargets->{$target}{targettype} eq "Ship"){
						my $totalvalidtargets=0;
						($lane, $olane, $totalvalidtargets) = findtargets ($gamedata->{turn}, $target);
				
						if ($totalvalidtargets == 0){	
							debuglog("no targets");
							next outer;
						}
						push @{$targets},  {
							'text' => $alltargets->{$target}{text},
							l => $lane,
							o => $olane,
							};
						}
						if ($alltargets->{$target}{targettype} eq "allcards"){
							
							debuglog("this is an allcards target, checking all cards for validity");
							my ($targets2, $totalvalidtargets) = findtargetsallzones($weare, $target);
						
							if ($totalvalidtargets == 0 ){
								debuglog("no targets for this trigger");
							
								return;
							}
							push @{$targets},  {
								'text' => $alltargets->{$target}{text},
								revealtargets => 1,
								l => [],
								o => [],
								raw => $targets2
							};
							
						}
			}
			$card2="$card:".to_json($targets);		
				debuglog("card2 is $card2");
				push (@canplay, $card2);
		}
	}
}
    outer: foreach my $card (@{$gamedata->{players}{$gamedata->{turn} }{hand} }){
       
		if (checkkeyword("Free", $card) > 0){
			debuglog("this is a free card! $card");
		}else {
			if ($gamedata->{objects}{$card}{cost} > $gamedata->{playsremaining})  {
                #we don't have enough actions!
                
				next;
			}
		}
        my $card2=$card;
        if ($gamedata->{objects}{$card}{CardType} eq "Ship"){
        
            my $targets= [{
                'text' => "Choose lane for Ship",
                    l => [1, 2, 3, 4, 5]
            }];
                
            $card2="$card:".to_json($targets);
        }elsif ($gamedata->{objects}{$card}{CardType}){
        	
            my $targets= [];
            my $lane;
            my $olane;
            foreach my $target (split (",",$gamedata->{objects}{$card}{targets} )){
                if (!$target){
                    next;
                }
                debuglog("Emergency: '$target'");
                if ($alltargets->{$target}{targettype} eq "Ship"){
					my $totalvalidtargets=0;
					($lane, $olane, $totalvalidtargets) = findtargets ($gamedata->{turn}, $target);
				
					if ($totalvalidtargets == 0){	
						next outer;
					}
					push @{$targets},  {
						'text' => $alltargets->{$target}{text},
						l => $lane,
						o => $olane,
						};
					}elsif ($alltargets->{$target}{targettype} eq "controller") {
						push @{$targets},   {
							'text' => $alltargets->{$target}{text},
							l => [],
							o => [],
						};
					}elsif ($alltargets->{$target}{targettype} eq "cardinhand"){
						my @raw;
						my $totalvalidtargets= 0;
						foreach my $card (@{$gamedata->{players}{$weare}{hand}} ){
							if (checktarget($target, $card, $weare)){
								push (@raw, $card);
								$totalvalidtargets+=1;
							}
						}
						push  @{$targets}, {
							'text' => $alltargets->{$target}{text},
							raw => \@raw,
							l => [],
							o => [],
						};
						if ($totalvalidtargets == 0 ) {
							next outer;
						}
					}
                }
            
            $card2="$card:".to_json($targets);
            }
        
        push (@canplay, $card2);
        }
        
        
        $canplay=join(";", @canplay);
        if (length ($canplay) == 0){
            $canplay="[]";
        }
        $dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, `handplayable`) VALUES(?, ?)", undef, ($gamedata->{players}{$gamedata->{turn}}{playerid}, $canplay ));
        $gamedata->{hidden}{$gamedata->{turn}}{handplayable}=$canplay;
}
sub checktrain {
	my $canplay="";
	my @canplay;

    outer: foreach my $card (@{$gamedata->{players}{$gamedata->{turn} }{hand} }){
        	
		if ($gamedata->{objects}{$card}{CardType} ne "Ship"){
			next;
		}
		if ($gamedata->{objects}{$card}{cost} > $gamedata->{playsremaining}){
                #we don't have enough gold!
                
			next;
		}
        my $card2=$card;
        my $targets= [{
            'text' => "Choose lane for Ship",
                l => [1, 2, 3, 4, 5]
        }];
                
        $card2="$card:".to_json($targets);
        push (@canplay, $card2);
        
        
        
        $canplay=join(";", @canplay);
        if (length ($canplay) == 0){
            $canplay="[]";
        }
        $dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, `handplayable`) VALUES(?, ?)", undef, ($player->{userId}, $canplay ));
	$gamedata->{hidden}{$gamedata->{turn}}{handplayable}=$canplay;
}
}

#check if this ship can battle, id is gameobject id. return 1 can battle, return 0 can not attack but will still defend itself
sub checkcanbattle {
	my $id=shift;
	if ($id <=0){
		return 0;
	}
	if ($gamedata->{objects}{$id}{ss}>0 and checkkeyword("Fast", $id)<=0 ){
		return 0;
	}
	if (checkkeyword("Blocker", $id) > 0){
		return 0;
	}
	return 1;
}


sub loadtargets {
	my $triggers = $dbh->selectall_hashref("SELECT * from `KS_cards`.`targets`", "targetid" );
	return $triggers;
}
sub loadeffects {
	my $triggers = $dbh->selectall_hashref("SELECT * from `KS_cards`.`effects`", "effectid" );
	return $triggers;
}
sub loadtriggers {
	my $triggers = $dbh->selectall_hashref("SELECT * from `KS_cards`.`triggers`", "triggerid" );
	return $triggers;
}
sub loadactivated {
	my $triggers = $dbh->selectall_hashref("SELECT * from `KS_cards`.`Activated`", "ActivateId" );
	return $triggers;
}
sub loadstatic {
	my $triggers = $dbh->selectall_hashref("SELECT * from `KS_cards`.`static`", "id" );
	return $triggers;
}
sub loadcards{
	my $cardnames=$dbh->selectall_hashref("SELECT * from `KS_cards`.`carddata`", "CardId" );
	my $cardids=$dbh->selectall_hashref("SELECT * from `KS_cards`.`carddata`", "Name" );
	my %allcards;
	foreach my $cardid (keys %$cardnames) {
		$allcards{$cardid}=$cardnames->{$cardid};
	}
	foreach my $cardname (keys %$cardids) {
		$allcards{$cardname}=$cardids->{$cardname};
		$allcards{lc($cardname)}=$cardids->{$cardname};

	}
	return \%allcards;
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



sub logmessage {
	my $message = shift;
	debuglog("turn is: $gamedata->{turn}");
	
	$dbh->do("INSERT INTO `GameMessages_$game` (`playerid`, `logmessage`, `turn`) VALUES(0, ?, ?)", undef, ($message, $gamedata->{turn}) );

}






1;
