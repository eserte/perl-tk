package Tk::Photo;

use vars qw($VERSION);
$VERSION = '4.002'; # $Id: //depot/Tkutf8/Photo/Photo.pm#2 $

use Tk qw($XS_VERSION);

use vars qw($VERSION);
$VERSION = '4.002'; # $Id: //depot/Tkutf8/Photo/Photo.pm#2 $

use base  qw(Tk::Image);

Construct Tk::Image 'Photo';

bootstrap Tk::Photo;

sub Tk_image { 'photo' }

Tk::Methods('blank','copy','data','formats','get','put','read','redither','write');

1;
__END__
