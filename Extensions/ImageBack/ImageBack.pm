package Tk::ImageBack;
require DynaLoader;
require Tk;


use vars qw($VERSION);
$VERSION = '3.004'; # $Id: //depot/Tk8/Extensions/ImageBack/ImageBack.pm#4$

@ISA = qw(DynaLoader);

bootstrap Tk::ImageBack $Tk::VERSION;

1;
__END__
