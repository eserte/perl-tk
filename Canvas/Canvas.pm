package Tk::Canvas; 
require Tk;
require DynaLoader;
@Tk::Canvas::ISA = qw(DynaLoader Tk::Widget); 
Tk::Widget->Construct('Canvas');

bootstrap Tk::Canvas;

sub Tk_cmd { \&Tk::canvas }

sub ClassInit
{
 my ($class,$mw) = @_;
 $mw->XYscrollBind($class);
 return $class;
}

1;

