package Tk::Mwm; 
require Tk;
require DynaLoader;

@ISA = qw(DynaLoader Tk::Widget);

bootstrap Tk::Mwm $Tk::VERSION; 

1;

