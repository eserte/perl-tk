package Tk::Photo;
require Tk;

use vars qw($VERSION @ISA);
$VERSION = '3.008'; # $Id: //depot/Tk8/Photo/Photo.pm#8$

use base  qw(Tk::Image);

Construct Tk::Image 'Photo';

bootstrap Tk::Photo $Tk::VERSION;

sub Tk_image { 'photo' }    

Tk::Methods("blank","copy","data","formats","get","put","read","redither","write");

1;
__END__
