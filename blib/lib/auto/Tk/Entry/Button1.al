# NOTE: Derived from .././blib/lib/Tk/Entry.pm.  Changes made here will be lost.
package Tk::Entry;

# Button1 --
# This procedure is invoked to handle button-1 presses in entry
# widgets. It moves the insertion cursor, sets the selection anchor,
# and claims the input focus.
#
# Arguments:
# w - The entry window in which the button was pressed.
# x - The x-coordinate of the button press.
sub Button1
{
 my $w = shift;
 my $x = shift;
 $Tk::selectMode = "char";
 $Tk::mouseMoved = 0;
 $Tk::pressX = $x;
 $w->icursor("@" . $x);
 $w->selection("from","@" . $x);
 if ($w->cget("-state") eq "normal")
  {
   $w->focus()
  }
}

1;
