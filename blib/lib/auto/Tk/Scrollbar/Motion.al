# NOTE: Derived from ../blib/lib/Tk/Scrollbar.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Scrollbar;

#line 99 "../blib/lib/Tk/Scrollbar.pm (autosplit into ../blib/lib/auto/Tk/Scrollbar/Motion.al)"
sub Motion
{
 my $w = shift;
 my $e = $w->XEvent;
 $w->activate($w->identify($e->x,$e->y));
}

# end of Tk::Scrollbar::Motion
1;
