package Tk::Bitmap;
require Tk;
require Tk::Image;

use vars qw($VERSION);
$VERSION = '2.005'; # $Id: //depot/Tk/Bitmap/Bitmap.pm#5$

@ISA = qw(Tk::Image);

Construct Tk::Image 'Bitmap';

bootstrap Tk::Bitmap $Tk::VERSION;

sub Tk_image { 'bitmap' }

1;
__END__
