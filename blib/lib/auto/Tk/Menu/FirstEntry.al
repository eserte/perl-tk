# NOTE: Derived from .././blib/lib/Tk/Menu.pm.  Changes made here will be lost.
package Tk::Menu;

# FirstEntry --
# Given a menu, this procedure finds the first entry that isn't
# disabled or a tear-off or separator, and activates that entry.
# However, if there is already an active entry in the menu (e.g.,
# because of a previous call to tkPostOverPoint) then the active
# entry isn't changed. This procedure also sets the input focus
# to the menu.
#
# Arguments:
# menu - Name of the menu window (possibly empty).
sub FirstEntry
{
 my $menu = shift;
 return if (!defined($menu) || $menu eq "" || !ref($menu));
 $menu->Enter;
 return if ($menu->index("active") ne "none");
 $last = $menu->index("last");
 return if ($last eq 'none');
 for ($i = 0;$i <= $last;$i += 1)
  {
   my $state = eval {local $SIG{__DIE__};  $menu->entrycget($i,"-state") };
   if (defined $state && $state ne "disabled" && !$menu->typeIS($i,"tearoff"))
    {
     $menu->activate($i);
     return;
    }
  }
}

1;
