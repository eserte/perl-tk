# NOTE: Derived from .././blib/lib/Tk/Menu.pm.  Changes made here will be lost.
package Tk::Menu;

# Escape --
# This procedure is invoked for the Cancel (or Escape) key. It unposts
# the given menu and, if it is the top-level menu for a menu button,
# unposts the menu button as well.
#
# Arguments:
# menu - Name of the menu window.
sub Escape
{
 my $menu = shift;
 if (!$menu->parent->IsMenu)
  {
   $menu->Unpost()
  }
 else
  {
   $menu->LeftRight(-1)
  }
}

1;
