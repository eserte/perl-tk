# NOTE: Derived from .././blib/lib/Tk/Entry.pm.  Changes made here will be lost.
package Tk::Entry;

# SeeInsert
# Make sure that the insertion cursor is visible in the entry window.
# If not, adjust the view so that it is.
#
# Arguments:
# w - The entry window.
sub SeeInsert
{
 my $w = shift;
 my $c = $w->index("insert");
#
# Probably a bug in your version of tcl/tk (I've not this problem
# when I test Entry in the widget demo for tcl/tk)
# index("\@0") give always 0. Consequence :
#    if you make <Control-E> or <Control-F> view is adapted
#    but with <Control-A> or <Control-B> view is not adapted
#
 my $left = $w->index("\@0");
 if ($left > $c)
  {
   $w->xview($c);
   return;
  }
 my $x = $w->width;
 while ($w->index("@" . $x) <= $c && $left < $c)
  {
   $left += 1;
   $w->xview($left)
  }
}

1;
