package Tk::Mwm; 
require Tk;
require DynaLoader;


use vars qw($VERSION);
$VERSION = '3.003'; # $Id: //depot/Tk8/Mwm/Mwm.pm#3$

@ISA = qw(DynaLoader);

bootstrap Tk::Mwm $Tk::VERSION; 

1;

