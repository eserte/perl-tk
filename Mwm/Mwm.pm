package Tk::Mwm; 
require Tk;
require DynaLoader;


use vars qw($VERSION);
$VERSION = '2.005'; # $Id: //depot/Tk/Mwm/Mwm.pm#5$

@ISA = qw(DynaLoader);

bootstrap Tk::Mwm $Tk::VERSION; 

1;

