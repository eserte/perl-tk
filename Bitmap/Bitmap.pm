package Tk::Bitmap;
require Tk;
require Tk::Image;

use vars qw($VERSION);
$VERSION = '3.006'; # $Id: //depot/Tk8/Bitmap/Bitmap.pm#6$

use base  qw(Tk::Image);

Construct Tk::Image 'Bitmap';

bootstrap Tk::Bitmap $Tk::VERSION;

sub Tk_image { 'bitmap' }

1;
__END__
