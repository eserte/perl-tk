package Tk::Bitmap;
require Tk;
require Tk::Image;

use vars qw($VERSION);
$VERSION = '3.003'; # $Id: //depot/Tk8/Bitmap/Bitmap.pm#3$

@ISA = qw(Tk::Image);

Construct Tk::Image 'Bitmap';

bootstrap Tk::Bitmap $Tk::VERSION;

sub Tk_image { 'bitmap' }

1;
__END__
