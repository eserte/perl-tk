# NOTE: Derived from .././blib/lib/Tk/Menu.pm.  Changes made here will be lost.
package Tk::Menu;

# tk_popup --
# This procedure pops up a menu and sets things up for traversing
# the menu and its submenus.
#
# Arguments:
# menu - Name of the menu to be popped up.
# x, y - Root coordinates at which to pop up the
# menu.
# entry - Index of a menu entry to center over (x,y).
# If omitted or specified as {}, then menu's
# upper-left corner goes at (x,y).
sub Post
{
 my $menu = shift;
 return unless (defined $menu);
 my $x = shift;
 my $y = shift;
 my $entry = shift;
 Unpost(undef) if (defined($Tk::popup) || defined($Tk::postedMb));
 $menu->PostOverPoint($x,$y,$entry);
 $menu->grabGlobal;
 $Tk::popup = $menu;
 $Tk::focus = $menu->focusCurrent;
 $menu->focus();
}

1;
