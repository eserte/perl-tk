package Tk::Pixmap;

use vars qw($VERSION);
$VERSION = '3.011'; # $Id: //depot/Tk8/TixPixmap/Pixmap.pm#11 $

use Tk qw($XS_VERSION);

use Tk::Image ();

use base  qw(Tk::Image);

Construct Tk::Image 'Pixmap';

bootstrap Tk::Pixmap;

sub Tk_image { 'pixmap' }

1;

