#!/usr/bin/perl -w
use strict;
use CGI qw(param);

$ksplatformshared::dbh=ksdbplatform::connectdb();

my $response = {};
ksplatformshared::init();
my $lastNumber=(param("lastNumber") or 0);
$response->{messages}=$ksplatformshared::dbh->selectall_arrayref("SELECT `date`, `messageId`, `message` from `messages` WHERE `messageId` > ? AND `userId` = ?", {Slice => {}}, ($lastNumber, $ksplatformshared::player->{userId}));



ksplatformshared::end($response);
