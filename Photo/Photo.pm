package Tk::Photo;
require Tk;

use vars qw($VERSION);
$VERSION = '2.005'; # $Id: //depot/Tk/Photo/Photo.pm#5$

@ISA = qw(Tk::Image);

Construct Tk::Image 'Photo';

bootstrap Tk::Photo $Tk::VERSION;

sub Tk_image { 'photo' }

1;
__END__
