package Tk::Mwm; 
require Tk;
require DynaLoader;

@ISA = qw(DynaLoader);

bootstrap Tk::Mwm $Tk::VERSION; 

1;

