# NOTE: Derived from ./blib/lib/Tk/Widget.pm.  Changes made here will be lost.
package Tk::Widget;

sub XYscrollBind
{
 my ($mw,$class) = @_;
 $mw->YscrollBind($class);
 $mw->XscrollBind($class);
}

1;
