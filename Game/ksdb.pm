#!/usr/bin/perl
use strict "vars";
use DBI;
package ksdb;
sub connectdb {
	my $dbh;
	my $host = "localhost";
	my $dbuser = "";
	my $dbpass = "";
	my $dbname = "KS_game";
	$dbh = DBI-> connect("DBI:mysql:$dbname:$host","$dbuser","$dbpass", {RaiseError=> 1, AutoCommit => 1,}) or die ("ACK! Can't connect to db");
	return $dbh;
}

sub checkconnect {
	my $dbh=shift;
	if ($dbh->ping){
		return $dbh;
	}
	return connectdb();
}
1;
