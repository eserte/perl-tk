package Tk::Photo;
require Tk;

use vars qw($VERSION);
$VERSION = '3.010'; # $Id: //depot/Tk8/Photo/Photo.pm#10$

use base  qw(Tk::Image);

Construct Tk::Image 'Photo';

bootstrap Tk::Photo $Tk::VERSION;

sub Tk_image { 'photo' }

Tk::Methods('blank','copy','data','formats','get','put','read','redither','write');

1;
__END__
