# NOTE: Derived from .././blib/lib/Tk/Menu.pm.  Changes made here will be lost.
package Tk::Menu;

# Leave --
# This procedure is invoked to handle Leave events for a menu. It
# deactivates everything unless the active element is a cascade element
# and the mouse is now over the submenu.
#
# Arguments:
# menu - The menu window.
# rootx, rooty - Root coordinates of mouse.
# state - Modifier state.
sub Leave
{
 my $menu = shift;
 my $rootx = shift;
 my $rooty = shift;
 my $state = shift;
 my $type;
 undef $Tk::window;
 return if ($menu->index("active") eq "none");
 return if ! defined $menu->Containing($rootx,$rooty);
 return if ($menu->typeIS("active","cascade") && 
            $menu->entrycget("active","-menu")->IS($menu->Containing($rootx,$rooty)));
 $menu->activate("none")
}

1;
