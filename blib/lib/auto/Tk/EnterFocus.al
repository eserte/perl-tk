# NOTE: Derived from ./blib/lib/Tk.pm.  Changes made here will be lost.
package Tk;

# focusFollowsMouse
#
# If this procedure is invoked, Tk will enter "focus-follows-mouse"
# mode, where the focus is always on whatever window contains the
# mouse. If this procedure isn't invoked, then the user typically
# has to click on a window to give it the focus.
#
# Arguments:
# None.

sub EnterFocus
{
 my $w  = shift;
 my $Ev = $w->XEvent;
 my $d  = $Ev->d;
 $w->Tk::focus() if ($d eq "NotifyAncestor" ||  $d eq "NotifyNonlinear" ||  $d eq "NotifyInferior");
}

1;
