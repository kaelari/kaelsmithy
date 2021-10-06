#!/usr/bin/perl -w
use strict "vars";
use lib qw(.);
use Digest::MD5 qw(md5_hex);
use shared;
use CGI param;
our $dbh=ksdbplatform::connectdb();
my $response = {};
init();

$response->{skus}=$dbh->selectall_arrayref("SELECT * FROM `sku`", {Slice =>{}});



end($response);
