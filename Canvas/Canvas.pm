package Tk::Canvas; 
require Tk;
require DynaLoader;
@Tk::Canvas::ISA = qw(DynaLoader Tk::Widget); 
Tk::Widget->Construct('Canvas');

bootstrap Tk::Canvas $Tk::VERSION;

sub Tk_cmd { \&Tk::canvas }

Tk::SubMethods ( 'create' => [qw(arc bitmap image line oval 
                                 polygon rectangle text window)],
                 'scan'   => [qw(mark dragto)],
                 'select' => [qw(from clear item to)],
               );


sub ClassInit
{
 my ($class,$mw) = @_;
 $mw->XYscrollBind($class);
 return $class;
}

1;

