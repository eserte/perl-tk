# NOTE: Derived from .././blib/lib/Tk/Menu.pm.  Changes made here will be lost.
package Tk::Menu;

# ButtonDown --
# Handles button presses in menus. There are a couple of tricky things
# here:
# 1. Change the posted cascade entry (if any) to match the mouse position.
# 2. If there is a posted menubutton, must grab to the menubutton so
#    that it can track mouse motions over other menubuttons and change
#    the posted menu.
# 3. If there's no posted menubutton (e.g. because we're a torn-off menu
#    or one of its descendants) must grab to the top-level menu so that
#    we can track mouse motions across the entire menu hierarchy.

#
# Arguments:
# menu - The menu window.
sub ButtonDown
{
 my $menu = shift;
 $menu->postcascade("active");
 if (defined $Tk::postedMb)
  {
   $Tk::postedMb->grabGlobal
  }
 else
  {
   while ($menu->transient
          && $menu->parent->IsMenu
          && $menu->parent->ismapped 
         )
    {
     $menu = $menu->parent;
    }
   $menu->grabGlobal;
  }
}

1;
