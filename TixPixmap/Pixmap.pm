package Tk::Pixmap; 

use vars qw($VERSION @ISA);
$VERSION = '3.004'; # $Id: //depot/Tk8/TixPixmap/Pixmap.pm#4$

use Tk ();
use Tk::Image ();

@ISA = qw(Tk::Image);

Construct Tk::Image 'Pixmap';

bootstrap Tk::Pixmap $Tk::VERSION; 

sub Tk_image { 'pixmap' }

1;

