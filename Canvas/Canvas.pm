package Tk::Canvas; 
require Tk;
@Tk::Canvas::ISA = qw(Tk::Widget); 
Construct Tk::Widget 'Canvas';

bootstrap Tk::Canvas $Tk::VERSION;

sub Tk_cmd { \&Tk::canvas }

use Tk::Submethods ( 'create' => [qw(arc bitmap image line oval 
                                 polygon rectangle text window)],
                     'scan'   => [qw(mark dragto)],
                     'select' => [qw(from clear item to)],
                    );

*CanvasBind  = \&Tk::bind;
*CanvasFocus = \&Tk::focus;

sub ClassInit
{
 my ($class,$mw) = @_;
 $mw->XYscrollBind($class);
 return $class;
}

1;

