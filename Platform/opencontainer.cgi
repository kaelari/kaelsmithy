#!/usr/bin/perl -w
use strict "vars";
use lib qw(. /usr/lib/cgi-bin/ksplatform);
use Digest::MD5 qw(md5_hex);
use CGI qw(param);
use Data::Dumper;
$ksplatformshared::dbh=ksdbplatform::connectdb();
my $response = {};
ksplatformshared::init();

my $container = param("container");
#first check we have such a container and that it exists i.e. it has a definition.

my $row= $ksplatformshared::dbh->selectrow_hashref("SELECT * from `Inventory` WHERE `userId` = ? and `sku` = ? and `number`>=1", undef, ($ksplatformshared::player->{userId}, $container));
unless ($row) {
	$response->{status}="failed";
	$response->{message}="We don't have one of those";
	ksplatformshared::end($response);
	exit;
}
my $containerrow = $ksplatformshared::dbh->selectrow_hashref("SELECT * from `containers` where `sku` = ? ", undef, ($container));
unless ($containerrow){
	$response->{status}="failed";
	$response->{message}="Not a container?";
	ksplatformshared::end($response);
	exit;
}
my $rows = $ksplatformshared::dbh->selectall_arrayref("SELECT * from `containers_data` WHERE `containerid` = ? ORDER BY slot ASC", {Slice=>{}}, ($containerrow->{containerid}));

my $slots= {};

foreach my $row (@{$rows}){
		if (!$slots->{$row->{slot}}) {
			
			$slots->{$row->{slot} } = [$row];
		}else {
			
			push (@{$slots->{$row->{slot}}}, $row);
		}
}


my $slot=1;
while ($slots->{$slot} ){
	
	my $totalweight =0;
	foreach my $row (@{$slots->{$slot}}){
		
		$totalweight += $row->{weight};
	}
	
	my $rand = rand($totalweight);
	
	my $finalrow;
	foreach my $row (@{$slots->{$slot}}){
		
		$rand -= $row->{weight};
		if ($rand<=0){
			#we pick this one;
			
			$finalrow = $row;
			last;
		}
	}
	
	if ($finalrow->{sku}) {
		# give specific item
		$response->{"newsku"}{$finalrow->{sku} } = $finalrow->{amount};
		ksplatformshared::grantitem($finalrow->{amount}, $finalrow->{sku}, 0, $ksplatformshared::player, "Silent");		
	}
	if ($finalrow->{cardtype}){
		my @restrictions = split(";", $finalrow->{cardtype}) ;
		my $string="";
		foreach my $restriction (@restrictions){ 
			$restriction =~/(.*?):(.*)/i;
			if ($string){
				$string .= "AND `$1` like '$2'";
			}else {
				$string .= "`$1` like '$2'";
			}
		}
		my $data=$ksplatformshared::dbh->selectrow_hashref("SELECT * from `carddata` WHERE $string ORDER BY rand()");
		my $sku = "card.".$data->{"CardId"};
		my $amount = $finalrow->{amount};
		
		while ($finalrow->{rerolls}>0){
			my $foo= $ksplatformshared::dbh->selectrow_hashref("SELECT * from `Inventory` WHERE `userId` = ? and `sku` = ? and `number` >= 4", undef, ($ksplatformshared::player->{userId}, $sku));
			if (!$foo) {
				last;
			}
			$data=$ksplatformshared::dbh->selectrow_hashref("SELECT * from `carddata` WHERE $string ORDER BY rand()");
			$sku = "card.".$data->{"CardId"};
			$finalrow->{rerolls}-=1;
		}
		if ($finalrow->{"fallbacksku"}){
			my $foo= $ksplatformshared::dbh->selectrow_hashref("SELECT * from `Inventory` WHERE `userId` = ? and `sku` = ? and `number` >= 4", undef, ($ksplatformshared::player->{userId}, $sku));
			if ($foo) {
				$sku = $finalrow->{"fallbacksku"};
				$amount = ($finalrow->{"fallbackamount"} or 1);
			}
		}
		if ($response->{"newsku"}{$sku}){
			$response->{"newsku"}{$sku } += $amount;
		}else {
		$response->{"newsku"}{$sku } = $amount;
		}
		ksplatformshared::grantitem($amount, $sku, 0, $ksplatformshared::player, "Silent");		
	}

	$slot+=1;
}


$ksplatformshared::dbh->do("UPDATE `Inventory` SET `number` = `number` - 1 WHERE `userId` = ? AND `sku` = ?", undef, ($ksplatformshared::player->{userId}, $container));
 




ksplatformshared::end($response);
