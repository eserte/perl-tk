package Tk::Mwm; 
require Tk;
require DynaLoader;


use vars qw($VERSION @ISA);
$VERSION = '3.004'; # $Id: //depot/Tk8/Mwm/Mwm.pm#4$

@ISA = qw(DynaLoader);

bootstrap Tk::Mwm $Tk::VERSION; 

1;

