#!/usr/bin/perl

use strict;
use warnings;

use CGI; # or CGI::Simple ?
use JSON::XS;
use Email::Stuff;

sub error {
    my $error_msg = shift;

    # we don't really need those since we're updating the page with Jemplate
    #my $return_link_url   = $cgi->param('return_link_url')   || q{};
    #my $return_link_title = $cgi->param('return_link_title') || q{};

    print encode_json { error => $error_msg }; 

    exit 0;
}

my $cgi = CGI->new();

print $cgi->header( -charset => 'UTF-8' );

my $subject   = $cgi->param('subject')  || q{};
my $name      = $cgi->param('realname') || q{};
my $email     = $cgi->param('email')    || q{};
my $text      = $cgi->param('text')     || q{};
my $recipient = q{andy@petdance.com}; # this shouldn't be in the form
my $from      = qq{$name <$email>};

if ( !$name || !$text ) {
    # a name and text are essential
    error('Missing name or text');
}

# this should work but it didn't for me
# maybe it was my sendmail definitions
# but i didn't have the time to debug it
Email::Stuff->from($from)
            ->to($recipient)
            ->text_body($text)
            ->subject($subject)
            ->send;

print encode_json { success => 'imminent' };

