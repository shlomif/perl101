#!/usr/bin/perl

# TODO:
#   - use Jemplate

use strict;
use warnings;

use CGI; # or CGI::Simple ?
use Email::Stuff;

sub error {
    my $cgi = shift;

    my $return_link_url   = $cgi->param('return_link_url')   || q{};
    my $return_link_title = $cgi->param('return_link_title') || q{};

}

my $cgi = CGI->new();

# make sure the form was submitted
$cgi->param('submit') || error($cgi);

my $subject   = $cgi->param('subject')  || q{};
my $name      = $cgi->param('realname') || q{};
my $email     = $cgi->param('email')    || q{};
my $text      = $cgi->param('text')     || q{};
my $recipient = q{andy@petdance.com}; # this shouldn't be in the form
my $from      = qq{$name <$email>};

if ( !$name || !$text ) {
    # a name and text are essential
    error($cgi);
}

Email::Stuff->from($from)
            ->to($recipient)
            ->text_body($text)
            ->subject($subject)
            ->send;

