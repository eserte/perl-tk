package Tk::Pixmap; 
use Tk ();
use Tk::Image ();

@ISA = qw(Tk::Image);

Construct Tk::Image 'Pixmap';

bootstrap Tk::Pixmap $Tk::VERSION; 

sub Tk_image { 'pixmap' }

1;

