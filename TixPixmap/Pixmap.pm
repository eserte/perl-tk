package Tk::Pixmap;

use vars qw($VERSION);
$VERSION = '3.007'; # $Id: //depot/Tk8/TixPixmap/Pixmap.pm#7$

use Tk ();
use Tk::Image ();

use base  qw(Tk::Image);

Construct Tk::Image 'Pixmap';

bootstrap Tk::Pixmap $Tk::VERSION;

sub Tk_image { 'pixmap' }

1;

