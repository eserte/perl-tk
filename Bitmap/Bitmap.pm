package Tk::Bitmap;
require Tk;
import  Tk qw($XS_VERSION);
require Tk::Image;

use vars qw($VERSION);
$VERSION = '3.010'; # $Id: //depot/Tk8/Bitmap/Bitmap.pm#10 $

use base  qw(Tk::Image);

Construct Tk::Image 'Bitmap';

bootstrap Tk::Bitmap;

sub Tk_image { 'bitmap' }

1;
__END__
