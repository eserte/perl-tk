package Tk::Pixmap; 

use vars qw($VERSION @ISA);
$VERSION = '3.005'; # $Id: //depot/Tk8/TixPixmap/Pixmap.pm#5$

use Tk ();
use Tk::Image ();

use base  qw(Tk::Image);

Construct Tk::Image 'Pixmap';

bootstrap Tk::Pixmap $Tk::VERSION; 

sub Tk_image { 'pixmap' }

1;

