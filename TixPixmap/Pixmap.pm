package Tk::Pixmap; 

use vars qw($VERSION);
$VERSION = '3.003'; # $Id: //depot/Tk8/TixPixmap/Pixmap.pm#3$

use Tk ();
use Tk::Image ();

@ISA = qw(Tk::Image);

Construct Tk::Image 'Pixmap';

bootstrap Tk::Pixmap $Tk::VERSION; 

sub Tk_image { 'pixmap' }

1;

