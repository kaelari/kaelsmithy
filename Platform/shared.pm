package ksplatformshared;
use strict "vars";
use lib qw(. /usr/lib/cgi-bin/ksplatform);
use Time::HiRes qw(gettimeofday);


use CGI::Carp qw(fatalsToBrowser set_message);
use CGI qw(param);
use POSIX qw(ceil floor);
use ksdbconnect;
use CGI::Cookie;
use Data::Dumper;
use DateTime;
use JSON;

$CGI::LIST_CONTEXT_WARN = 0;
our $gamedb = 'KS_Platform';
our $dbh;
our $player;
our $levels;
our $allcards;
our $achievements;
our $loggedin= 0 ;
startup();


sub startup {
	$dbh=ksdbplatform::connectdb();
	loadlevels();
	$achievements = loadachievements();
	$allcards = loadcards();
}

sub init {
	initquiet();
}
sub initquiet {
	my %cookies = CGI::Cookie->fetch;
	$dbh->do("USE $gamedb");
	my $sid = param("session");
	if (!$sid){
		
		my $response={};
		$response -> {status} = "failed";
		$response->{message} = "No session found";
		end($response);
	}
	my $sql = "SELECT * from sessionId WHERE session like ?;";
	my $sessiondata=$dbh->selectrow_hashref($sql, undef, ($sid));
	$sql="SELECT * from `Users` where `userId` = ?;";
	$player = $dbh->selectrow_hashref($sql, undef, $sessiondata->{userId});
			
		
	
	if ($player->{userId}){
        
		$loggedin=1;
	}else {
        $loggedin = 0;
	}
	
}

sub loadlevels {
	return $levels = $dbh->selectall_hashref("SELECT * from `levels`", "level"); 
}
sub loadachievements {
	return $dbh->selectall_hashref("SELECT * from `Achievements`", "achievementId"); 
}
sub grantxp {
	my $amount=shift;
	my $who=(shift or $player);
	return unless ($who);
	if (ref $who ne "hash") {
		$who = $dbh->selectrow_hashref("SELECT * from `Users` WHERE `userid` = ?", undef, ($who) );
		
	}
	$who->{currentexp} += $amount;
	while ($who->{currentexp} >= ($levels->{$who->{level}}{exprequired} or 1000 )) {
		$who->{currentexp} -= ($levels->{$who->{level}}{exprequired} or 1000);
		$who->{level}+=1;
		grantitems( $levels->{$who->{level}}{reward1}, $who);
		grantitems( $levels->{$who->{level}}{reward2}, $who);
		grantitems( $levels->{$who->{level}}{reward3}, $who);
		grantitems( $levels->{$who->{level}}{reward4}, $who);
		
	}
	
	$dbh->do("UPDATE `Users` SET `currentexp` = ?, `level` = ? WHERE `userid` = ?", undef, ($who->{currentexp}, $who->{level}, $who->{userId}));
	sendmessage("EXP:$who->{currentexp}", $who->{userId});
	sendmessage("LEVEL:$who->{level}", $who->{userId});
	 
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

sub checkadmin {
        if ($player->{admin} > 0 ){
            return 1;
        }
		return 0;
	
	
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






sub getdeckname{
	my $id=shift;
        return $id unless ($id);
	my $data=$dbh->selectrow_hashref("SELECT * from `Decks` where `deckId` = ?", undef, $id);
	return $data->{deckname};
}

sub getusername{
	my $id=shift;
        return $id unless ($id);
	my $data=$dbh->selectrow_hashref("SELECT * from `Users` where `userId` = ?", undef, $id);
	return $data->{username};
}
sub getuserid{
        my $id=shift;
        return $id unless ($id);
	my $data=$dbh->selectrow_hashref("SELECT * from Players where solforgename = ?", undef, ($id));
	return $data->{id};  
}

sub localDate {
	my ($unix_time,$zone, $clock, $short) = @_;
	
	my $dt;
	if ( $unix_time )
	{
		$dt = DateTime->from_epoch( epoch => $unix_time );
	}
	else 
	{
		$dt = DateTime->now();
	}
	$zone = 'UTC' unless ($zone);
	$dt->set_time_zone($zone);
	
	my $timezone;
	
	my $min  = $dt->min;
	my $hour = $dt->hour;
	my $day  = Lingua::EN::Numbers::Ordinate::ordinate($dt->day);
	my $year = $dt->year;
	my $month = $dt->month_abbr;
	$min = "0".$min if ($min < 10);
	my $pm;
	if ($clock ){
		
		if ($hour>=12){
			$hour-=12;
			$pm="PM";
		}else {
			$pm="AM";
		}
		if ($hour==0){
			$hour=12;
		}
	}else {
		$pm="";
	}

    if ($zone) {
    	$timezone = $zone;
		$timezone =~ s|/| - |gis;
		$timezone =~ s|_| |gis;
    }
    else {
    	$timezone = 'GMT';
    }
    return $_ = ($short) ? "$day $month, $year $hour:$min"." $pm" : $dt->day_name." $day $month, $year. $hour:$min"." $pm ($timezone)";
}
sub timeleft {
	my $time=shift;
	my $past="";
	if ($time<0){
		$time=abs($time);
		
		$past=" ago";
	}
	my $finalstring;
	my @final;
	my $days=int($time/(60*60*24));
	my $hours=int($time/(60*60)) % (24);
	my $minutes=int($time/60) % (60);
	my $seconds = $time % 60;
	my $z=0;
	if ($days){
		if ($days>1){
			push @final, commify($days)." days";
		}else {
			push @final, "1 day";
		}
		$z++;
	}
	if ($hours){
		if ($hours>1){
			push @final, "$hours hours";
		} else {
			push @final, "1 hour";
		}
		$z++;
	}
	if ($minutes){
		if ($minutes>1){
			push @final, "$minutes minutes";
		} else {
			push @final, "1 minute",
		}
		$z++;
	}
	if ($seconds and $z<3 ){
		if ($seconds>1){
			push @final, "$seconds seconds";
		}else {
			push @final, "1 second";
		}
	}
	return stringify(@final).$past;
	
	#return "$days days, $hours hours, $minutes minutes, and $seconds seconds";
}


sub stringify {
	my @entries=@_;
	if (@entries<=1){
		return "@entries";
	}
	$entries[-1]="and $entries[-1]";
	if (@entries>2){
		return join(", ", @entries);
	}
	return join(" ", @entries);
	
}

sub grantprizes {
    my $prize=shift;
    my $who = shift;
    my $prizerows = $dbh->selectall_arrayref("SELECT * from `prize_data` WHERE `prizeid` = ?", {Slice=>{}}, ($prize));
    foreach my $prize (@{$prizerows}){
        foreach my $slot (1..5){
            my @options = split(/,/, $prize->{"slot$slot"});
            my $maxweight;
            
            foreach my $option (@options){
                my ($chance, $number, $sku) = split(/:/, $option);
                $maxweight += $chance;
            }
            my $finalweight=rand($maxweight);
            foreach my $option (@options){
                my ($chance, $number, $sku) = split(/:/, $option);
                $finalweight -= $chance;
                if ($finalweight<=0 ){
                    #this one!
                    grantitem($number, $sku, 1, $who, 0);
                    last;
                }
            }
            
        }
    
    }
    
}
sub grantitems {
	my $string=shift;
	my $who=shift;
	return unless ($string and $who);
	my ($sku, $number) = split(":", $string);
	return unless ($sku and $number);
	grantitem($number, $sku, 0, $who);
	
}
sub grantitem {
    
    my $number=shift;
    my $sku = shift;
    my $accountbound=(shift or 1);
    my $who=(shift or $player);
    my $silent=(shift or 0);
    if (! ref $who){
		$who=$dbh->selectrow_hashref("SELECT * FROM `Users` WHERE `userId` = ?", undef, ($who));
    }
    my $row = $dbh->selectrow_hashref("SELECT * from `Inventory` WHERE `userid` = ? and `sku` = ? and `accountbound` = ? ", undef, ($who->{"userId"}, $sku, $accountbound));
    if ($row){
        $dbh->do("UPDATE `Inventory` SET `number` = `number` + ? WHERE `rowid` = ?", undef, ($number, $row->{"rowid"}));
    }else {
        $dbh->do("INSERT INTO `Inventory`(`userid`, `sku`, `number`, `accountbound`) VALUES(?,?,?,?)", undef, ($who->{"userId"}, $sku, $number, $accountbound));
    }
    
    if (!$silent){
		$dbh->do("INSERT INTO `messages` (`userid`, `message`) VALUES (?, ?)", undef, ($who->{"userId"}, "new:$sku:$number"));
    }
}

# Add progress to a player's achievement
sub addachievement {
	my $who=shift;
	my $achievement = shift;
	my $progress = shift;
	my $have=$dbh->selectrow_hashref("SELECT * FROM `playerAchievements` WHERE `userId` = ? AND `achievementId` = ?", undef, ($who, $achievement));
	#already have completed this achievement, no need to add progress
	return if ($have->{completed});
    if ($have->{userId}){ 
			$have->{progress}+=$progress;
			if ($have->{progress} > $achievements->{$achievement}{progressneeded}) {
				#we have just completed this achievement
				grantachievement($who, $achievement);
			}else {
				$dbh->do("UPDATE `playerAchievements` SET `progress` = ? WHERE `rowid` = ?", undef, ($have->{progress}, $have->{rowid}));
				
			}
    }else {
    	warn "We need to insert a new row for progress tracking";
		if ($progress >= $achievements->{$achievement}{progressneeded} ){
			warn "granting this achievement $who and $achievement";
			grantachievement($who, $achievement);
		}else {
			warn "inserting now, $progress, $who, $achievement";
			$dbh->do("INSERT INTO `playerAchievements`(`progress`, `userid`, `achievementId`) VALUES (?, ?,?)", undef, ($progress, $who, $achievement));
		}
	}
}
sub grantachievement {
	my $who=shift;
	my $achievement=shift;
        
	return unless ($who and $achievement);
	#already have?
	my $have=$dbh->selectrow_hashref("SELECT * FROM `playerAchievements` WHERE `userId` = ? AND `achievementId` = ?", undef, ($who, $achievement));
	return if ($have->{completed});
        warn("granting this achievement");
	my $achievementData=$dbh->selectrow_hashref("SELECT * from `Achievements` WHERE `achievementId` = ?", undef, ($achievement));
	my $row=$dbh->selectrow_hashref("SELECT * from `playerAchievements` WHERE `achievementId` = ? and `userid` = ?", undef, ($achievement, $who));
	if ($row){
		$dbh->do("UPDATE `playerAchievements` SET `completed` = true WHERE `rowid` = ?", undef, ($row->{rowid}));
	}else {
		$dbh->do("INSERT INTO `playerAchievements`(`achievementId`, `userId`, `completed`) VALUES(?, ?, true)",undef, ($achievement, $who));
	}
	if ($achievementData->{prizeSku}){
            ##Should grant this item here.
	}
	if ($achievementData->{exp}){
		
		grantxp($achievementData->{exp}, $who );
	}
	if ($achievementData->{precon}){
		my $deck = $dbh->selectrow_hashref("SELECT * from `Decks` WHERE `deckid` = ?", undef , ($achievementData->{precon}));
		my @cards = split(/, ?/, $deck->{cards});
		foreach my $card (@cards){
			grantitem(1, "card.$card", 0, $who, 1);
		}		
		$dbh->do("INSERT INTO `Decks` (`deckname`, `cards`, `ownerid`, `formats`) VALUES (?,  ?, ?, ?)", undef, ($deck->{deckname}, $deck->{cards}, $who, $deck->{formats}));
	}
	sendmessage("A$achievement", $who);
	
	return 1;
}
sub sendmessage {
    my $message=shift;
    my $to=(shift or $player->{userId});
    if (length($message)> 256){
        warn "Too long!";
    }
    
    
    $dbh->do("INSERT INTO `messages`(userId, message) VALUES( ?, ?)", undef, ($to, $message));
}
sub sendemail {
	my $to=shift;
	my $subject=shift;
	my $message=shift;
	use Email::Valid;
	use MIME::Lite;
	
	my $who=$dbh->selectrow_hashref("SELECT * from `Players` WHERE `id` = ?", undef, $to);
	my $core = $dbh->selectrow_hashref("SELECT * from `ladder_shared`.`Userinfo` WHERE `userid` = ?", undef, ($who->{coreid}));
	return if ($who->{neveremail} or $core->{neveremail});
	return if (!$message);
	my $address = Email::Valid->address($core->{email});
	return unless ($address);
	my $from="kaelari's yet to be named game";
	eval {
	my $msg = MIME::Lite->new(
                 From    => $from,
                 To      => "$who->{username} <$address>",
                 Subject => $subject,
		Type => 'text/html',
                 Data => $message,
                );
	
	$msg->send();
	}
}



1;
