#!/usr/bin/perl -w
package draft;

use strict "vars";
use lib qw(. /usr/lib/cgi-bin/ksplatform);
use shared;
use CGI qw(param);
use JSON;
$ksplatformshared::dbh=ksdbplatform::connectdb();
my $response = {};
ksplatformshared::init();

my $eventid = param("event");
my $eventdata= $ksplatformshared::dbh->selectrow_hashref("SELECT * from `Playerevents` where `playerid` = ? and `eventid` = ? and `finished` =0", undef, ($ksplatformshared::player->{userId}, $eventid));
our $baseeventdata = $ksplatformshared::dbh->selectrow_hashref("SELECT * from `events` WHERE `eventid` = ?", undef, ($eventid));

if ($eventdata->{Status} ne "Drafting"){
    $response->{status}="failed";
    $response->{message}="Not drafting";
    ksplatformshared::end($response);
}

my $draftdata;
if ($eventdata->{DraftStatus}){
    #loading existing data here
    $draftdata = from_json($eventdata->{DraftStatus});
    
    my $success = 0;
    if (my $pick=param("pick")){
        foreach my $card (@{$draftdata->{cardsavailable}}){
            
            if ($card == $pick){
                $success = 1;
            }
        }
        if ($success){
            push (@{$draftdata->{cardspicked}}, $pick);
            
            my $faction = $ksplatformshared::allcards->{$pick}{Faction};
            $draftdata->{factions}{$faction}+=1;
            if ( (int @{$draftdata->{cardspicked}}) >= $baseeventdata->{Packs}) {
                #done with this draft
                
                undef $draftdata;
                $ksplatformshared::dbh->do("UPDATE `Playerevents` SET `Status` = \"Entered\" WHERE `rowid` = ?", undef, ($eventdata->{rowid}));
                $response->{result}="Draft Complete";
                my $string= "";
                $ksplatformshared::dbh->do("UPDATE `Playerevents` SET `DraftStatus` = ? WHERE `rowid` = ?", undef, ($string, $eventdata->{rowid}));
                my $data=from_json($eventdata->{DraftStatus});
                my $cards = join(",", @{$data->{cardspicked}});
                
                $ksplatformshared::dbh->do("INSERT INTO `Decks`(`eventid`, `ownerid`, `deckname`, `cards`) values(?, ?, 'Draft Deck', ?)", undef, ($eventdata->{eventid}, $ksplatformshared::player->{userId}, $cards));
                my $deckid = $ksplatformshared::dbh->{'mysql_insertid'};
                $ksplatformshared::dbh->do("UPDATE `Playerevents` SET `deckid` = ? WHERE `rowid` = ?", undef, ($deckid, $eventdata->{rowid}));
               
                
                
                ksplatformshared::end($response);
                
            }else {
                $draftdata->{cardsavailable}=generatepicks($draftdata);
            }
            my $string= to_json($draftdata);
            $ksplatformshared::dbh->do("UPDATE `Playerevents` SET `DraftStatus` = ? WHERE `rowid` = ?", undef, ($string, $eventdata->{rowid}));
        }else {
            print "Content-type: text\n\n";
            print "Can't pick that card!";
        }
        
        
    }
    
    
    
    
}else {
    #this should do more
    $draftdata->{cardspicked} = [];
    $draftdata->{factions}={};
    $draftdata->{cardsavailable}= generatepicks($draftdata);
    my $string= to_json($draftdata);
    $ksplatformshared::dbh->do("UPDATE `Playerevents` SET `DraftStatus` = ? WHERE `rowid` = ?", undef, ($string, $eventdata->{rowid}));

}

$response->{result}=$draftdata;


ksplatformshared::end($response);


sub generatepicks {
	my $draftdata=shift;
    my $rarity = "common";
    if (rand(100) < 0){
       # $rarity="rare";
    }
    my $factions="";
    if (scalar keys %{$draftdata->{factions}} >= 2 ){
    	my @string;
    	foreach my $faction (keys %{$draftdata->{factions}}){
				push (@string, "`faction` like \"$faction\"");
    	}
		$factions = "AND (".join(" or ", @string)." )";
	}
    my $cards=$ksplatformshared::dbh->selectall_arrayref("SELECT `cardid` FROM `KS_cards`.`carddata` WHERE `rarity` = ? and `level` = 1 $factions ORDER BY RAND() limit ?", {Slice=>{}}, ($rarity, $baseeventdata->{CardsPerPack}));
    
    my @cardstopick;
    foreach my $card (@{$cards}){
        push (@cardstopick, $card->{"cardid"});
    }
    
    
    return \@cardstopick;
}


