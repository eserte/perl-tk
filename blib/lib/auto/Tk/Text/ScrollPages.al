# NOTE: Derived from .././blib/lib/Tk/Text.pm.  Changes made here will be lost.
package Tk::Text;

# ScrollPages --
# This is a utility procedure used in bindings for moving up and down
# pages and possibly extending the selection along the way. It scrolls
# the view in the widget by the number of pages, and it returns the
# index of the character that is at the same position in the new view
# as the insertion cursor used to be in the old view.
#
# Arguments:
# w - The text window in which the cursor is to move.
# count - Number of pages forward to scroll; may be negative
# to scroll backwards.
sub ScrollPages
{
 my $w = shift;
 my $count = shift;
 my @bbox = $w->bbox('insert');
 $w->yview('scroll',$count,'pages');
 if (!@bbox)
  {
   return $w->index("@" . int($w->height/2) . "," . 0);
  }
 my $x = int($bbox[0]+$bbox[2]/2);
 my $y = int($bbox[1]+$bbox[3]/2);
 return $w->index("@" . $x . "," . $y);
}

1;
