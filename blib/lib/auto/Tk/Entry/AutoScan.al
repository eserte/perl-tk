# NOTE: Derived from .././blib/lib/Tk/Entry.pm.  Changes made here will be lost.
package Tk::Entry;

# AutoScan --
# This procedure is invoked when the mouse leaves an entry window
# with button 1 down.  It scrolls the window left or right,
# depending on where the mouse is, and reschedules itself as an
# "after" command so that the window continues to scroll until the
# mouse moves back into the window or the mouse button is released.
#
# Arguments:
# w - The entry window.
# x - The x-coordinate of the mouse when it left the window.
sub AutoScan
{
 my $w = shift;
 my $x = shift;
 if ($x >= $w->width)
  {
   $w->xview("scroll",2,"units")
  }
 elsif ($x < 0)
  {
   $w->xview("scroll",-2,"units")
  }
 else
  {
   return;
  }
 $w->MouseSelect($x);
 $w->RepeatId($w->after(50,"AutoScan",$w,$x))
}

1;
