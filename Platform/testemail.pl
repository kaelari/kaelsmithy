#!/usr/bin/perl -w
use strict;
use warnings;
use Email::Valid;
use MIME::Lite;
	
my $to = "zjh37rjwbknq2i\@dkimvalidator.com";
my $subject = "test";
my $message = "This is a test";
my $from="kaelaris yet to be named game<userhelp\@solforgeladder.com>";
	my $msg = MIME::Lite->new(
                 From    => $from,
                 To      => "testing <$to>",
                 Subject => $subject,
		Type => 'text/html',
                 Data => $message,
                );
	
	$msg->send();
	