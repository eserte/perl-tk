# NOTE: Derived from .././blib/lib/Tk/Menu.pm.  Changes made here will be lost.
package Tk::Menu;

# Motion --
# This procedure is called to handle mouse motion events for menus.
# It does two things. First, it resets the active element in the
# menu, if the mouse is over the menu.  Second, if a mouse button
# is down, it posts and unposts cascade entries to match the mouse
# position.
#
# Arguments:
# menu - The menu window.
# y - The y position of the mouse.
# state - Modifier state (tells whether buttons are down).
sub Motion
{
 my $menu = shift;
 my $y = shift;
 my $state = shift;
 if ($menu->IS($Tk::window))
  {
   $menu->activate("\@$y")
  }
 if (($state & 0x1f00) != 0)
  {
   $menu->postcascade("active")
  }
}

1;
