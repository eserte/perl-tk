# NOTE: Derived from .././blib/lib/Tk/Listbox.pm.  Changes made here will be lost.
package Tk::Listbox;

#
# Bind --
# This procedure is invoked the first time the mouse enters a listbox
# widget or a listbox widget receives the input focus. It creates
# all of the class bindings for listboxes.
#
# Arguments:
# event - Indicates which event caused the procedure to be invoked
# (Enter or FocusIn). It is used so that we can carry out
# the functions of that event in addition to setting up
# bindings.

sub xyIndex
{
 my $w = shift;
 my $Ev = $w->XEvent;
 return $w->index($Ev->xy);
}

1;
