# NOTE: Derived from .././blib/lib/Tk/Menu.pm.  Changes made here will be lost.
package Tk::Menu;

# PostOverPoint --
# This procedure posts a given menu such that a given entry in the
# menu is centered over a given point in the root window. It also
# activates the given entry.
#
# Arguments:
# menu - Menu to post.
# x, y - Root coordinates of point.
# entry - Index of entry within menu to center over (x,y).
# If omitted or specified as {}, then the menu's
# upper-left corner goes at (x,y).
sub PostOverPoint
{
 my $menu = shift;
 my $x = shift;
 my $y = shift;
 my $entry = shift;
 if (defined $entry)
  {
   if ($entry == $menu->index("last"))
    {
     $y -= ($menu->yposition($entry)+$menu->height)/2;
    }
   else
    {
     $y -= ($menu->yposition($entry)+$menu->yposition($entry+1))/2;
    }
   $x -= $menu->reqwidth/2;
  }
 $menu->post($x,$y);
 if (defined($entry) && $menu->entrycget($entry,"-state") ne "disabled")
  {
   $menu->activate($entry)
  }
}

1;
