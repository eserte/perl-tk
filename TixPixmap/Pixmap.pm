package Tk::Pixmap;

use vars qw($VERSION);
$VERSION = '4.002'; # $Id: //depot/Tkutf8/TixPixmap/Pixmap.pm#2 $

use Tk qw($XS_VERSION);

use Tk::Image ();

use base  qw(Tk::Image);

Construct Tk::Image 'Pixmap';

bootstrap Tk::Pixmap;

sub Tk_image { 'pixmap' }

1;

