# NOTE: Derived from .././blib/lib/Tk/Scrollbar.pm.  Changes made here will be lost.
package Tk::Scrollbar;

# tkScrollButtonUp --
# This procedure is invoked when a button is released in a scrollbar.
# It cancels scans and auto-repeats that were in progress, and restores
# the way the active element is displayed.
#
# Arguments:
# w -		The scrollbar widget.
# x, y -	Mouse coordinates.

sub ButtonUp
{my $w = shift;
 my $e = $w->XEvent;
 $w->CancelRepeat;
 $w->configure("-activerelief" => "raised");
 $w->EndDrag($e->x,$e->y);
 $w->activate($w->identify($e->x,$e->y));
}

1;
