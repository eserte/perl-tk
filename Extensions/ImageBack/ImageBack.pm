package Tk::ImageBack;
require DynaLoader;

use vars qw($VERSION);
$VERSION = '3.010'; # $Id: //depot/Tk8/Extensions/ImageBack/ImageBack.pm#10 $

use Tk qw($XS_VERSION);

use base  qw(DynaLoader);

bootstrap Tk::ImageBack;

1;
__END__
