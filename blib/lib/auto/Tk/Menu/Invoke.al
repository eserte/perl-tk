# NOTE: Derived from .././blib/lib/Tk/Menu.pm.  Changes made here will be lost.
package Tk::Menu;

# Invoke --
# This procedure is invoked when button 1 is released over a menu.
# It invokes the appropriate menu action and unposts the menu if
# it came from a menubutton.
#
# Arguments:
# w - Name of the menu widget.
sub Invoke
{
 my $w = shift;
 my $type = $w->type("active");
 if ($w->typeIS("active","cascade"))
  {
   $w->postcascade("active");
   $menu = $w->entrycget("active","-menu");
   $menu->FirstEntry() if (defined $menu);
  }
 elsif ($w->typeIS("active","tearoff"))
  {
   $w->Unpost();
   $w->TearOffMenu();
  }
 else
  {
   $w->Unpost();
   $w->invoke("active")
  }
}

1;
