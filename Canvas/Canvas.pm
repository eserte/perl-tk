# simply split out of Tk-a5's Tk.pm

package Tk::Canvas; 
require Tk;
require DynaLoader;

@ISA = qw(DynaLoader Tk::Widget); 

Tk::Widget->Construct('Canvas');

bootstrap Tk::Canvas;

sub Tk_cmd { \&Tk::canvas }

1;

