# NOTE: Derived from .././blib/lib/Tk/Menubutton.pm.  Changes made here will be lost.
package Tk::Menubutton;

# Leave --
# This procedure is invoked when the mouse leaves a menubutton widget.
# It de-activates the widget.
#
# Arguments:
# w - The name of the widget.
sub Leave
{
 my $w = shift;
 $Tk::inMenubutton = undef;
 if ($w->cget("-state") eq "active")
  {
   $w->configure("-state","normal")
  }
}

1;
