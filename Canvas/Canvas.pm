package Tk::Canvas; 
require Tk;
@Tk::Canvas::ISA = qw(Tk::Widget); 
Construct Tk::Widget 'Canvas';


use vars qw($VERSION);
$VERSION = '3.004'; # $Id: //depot/Tk8/Canvas/Canvas.pm#4$

bootstrap Tk::Canvas $Tk::VERSION;

sub Tk_cmd { \&Tk::canvas }

Tk::Methods("addtag","bbox","bind","canvasx","canvasy","coords","create",
            "dchars","delete","dtag","find","focus","gettags","icursor",
            "index","insert","itemcget","itemconfigure","lower","move",
            "postscript","raise","scale","scan","select","type","xview","yview");

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

