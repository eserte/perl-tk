# NOTE: Derived from .././blib/lib/Tk/Scrollbar.pm.  Changes made here will be lost.
package Tk::Scrollbar;

sub Motion
{
 my $w = shift;
 my $e = $w->XEvent;
 $w->activate($w->identify($e->x,$e->y));
}

1;
