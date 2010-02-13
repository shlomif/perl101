#!/usr/bin/perl

use strict;
use warnings;

use File::stat;
use File::Spec;
use File::Slurp;
use Digest::MD5 'md5_hex';
use CGI::Simple;
use Authen::Captcha;
use GD::SecurityImage;

sub create_formula {
    my @numbers   = ( 0 .. 20 );
    my %operators = (
        '+' => sub { $_[0] + $_[1] },
        '-' => sub { $_[0] - $_[1] },
        '*' => sub { $_[0] * $_[1] },
        '/' => sub { $_[0] * $_[1] },
    );
    my ( $num1, $op, $num2, $accepted );

    while ( ! $accepted ) {
        $num1 = $numbers[ rand scalar @numbers ];
        $num2 = $numbers[ rand scalar @numbers ];
        $op   = ( keys %operators )[ rand scalar keys %operators ];

        # avoiding edge cases in division
        if ( $op eq '/' ) {
            if ( $num2 == 0 ) {
                # avoiding division by zero
                next;
            } elsif ( $num1 % $num2 != 0 ) {
                # check if easily divisable
                next;
            }
        }

        $accepted++;
    }

    return [ "$num1  $op  $num2", $operators{$op}->( $num1, $num2 ) ];
}

sub create_image {
    my $text = shift;

    # Create a normal image
    my $image = GD::SecurityImage->new(
        width   => 100,
        height  => 50,
        lines   => 3,
        #gd_font => 'giant',
        rndmax  => 3,
    );

    $image->random($text);
    $image->create(normal => 'rect');

    return $image;
}

my $cgi                  = CGI::Simple->new();
my $data_folder          = 'captchas';
my ( $formula, $result ) = @{ create_formula() };
my $md5sum               = md5_hex($result);
my $image                = create_image($formula);
my $really_delete        = 1;  # set to 0 or '' for testing purposes
my $captcha_timeout      = 10; # allow them to exit for 1 minute

-d $data_folder || die "Cannot find data folder ($data_folder)";

my ( $image_data, $mime_type, $random_number ) = $image->out;
my $image_filename = File::Spec->catfile( $data_folder, "$md5sum.png" );

# write the new file
write_file( $image_filename, { binmode => ':raw' }, $image_data );

# delete older files
my $captcha_regex = qr/^\w+\.png$/;

foreach my $file ( read_dir($data_folder) ) {
    $file =~ $captcha_regex || next;
    my $filename = File::Spec->catfile( $data_folder, $file );

    if ( stat($filename)->ctime() < ( time() - $captcha_timeout ) ) {
        $really_delete && unlink $filename;
    }
}

