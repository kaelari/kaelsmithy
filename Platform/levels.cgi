#!/usr/bin/perl -w
use strict "vars";
use lib qw(.);
use Digest::MD5 qw(md5_hex);
use CGI param;
my $response = {};
ksplatformshared::init();
$response->{levels} = $ksplatformshared::levels;
$response->{exp} =$ksplatformshared::player->{"currentexp"};
$response->{level} = $ksplatformshared::player->{"level"};

ksplatformshared::end($response);
