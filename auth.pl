#!/usr/bin/perl

use strict;
use warnings;

use File::Spec;
use File::Slurp;
use Digest::MD5 'md5_hex';
use CGI::Simple;
use Authen::Captcha;
use GD::SecurityImage;

sub create_formula {
    my @operators = ( qw( + - * / ) );
    my @numbers   = ( 0 .. 20 );
    my ( $num1, $op, $num2, $accepted );

    while ( ! $accepted ) {
        $num1 = $numbers[   rand scalar @numbers   ];
        $num2 = $numbers[   rand scalar @numbers   ];
        $op   = $operators[ rand scalar @operators ];

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

    return "$num1  $op  $num2";
}

sub create_image {
    my $text = shift;

    # Create a normal image
    my $image = GD::SecurityImage->new(
        width   => 100,
        height  => 50,
        lines   => 5,
        #gd_font => 'giant',
        rndmax  => 3,
    );

    $image->random($text);
    $image->create(normal => 'rect');

    return $image;
}

my $cgi           = CGI::Simple->new();
my $cur_dir       = File::Spec->curdir();
my $data_folder   = $cur_dir;
my $output_folder = $cur_dir;
my $formula       = create_formula();
my $md5sum        = md5_hex($formula);
my $image         = create_image($formula);

my ( $image_data, $mime_type, $random_number ) = $image->out;

write_file(
    File::Spec->catfile( $data_folder, "$md5sum.png" ),
    { binmode => ':raw' },
    $image_data,
);

