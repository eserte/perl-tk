# NOTE: Derived from .././blib/lib/Tk/Menubutton.pm.  Changes made here will be lost.
package Tk::Menubutton;

# ButtonUp --
# This procedure is invoked to handle button 1 releases for menubuttons.
# If the release happens inside the menubutton then leave its menu
# posted with element 0 activated. Otherwise, unpost the menu.
#
# Arguments:
# w - The name of the menubutton widget.
sub ButtonUp
{
 my $w = shift;
 if (defined($Tk::postedMb) && $Tk::postedMb == $w && 
     defined($Tk::inMenubutton) && $Tk::inMenubutton == $w)
  {
   my $menu = $Tk::postedMb->cget("-menu");
   $menu->FirstEntry() if (defined $menu);
  }
 else
  {
   Tk::Menu->Unpost(undef); # fixme
  }
}

1;
