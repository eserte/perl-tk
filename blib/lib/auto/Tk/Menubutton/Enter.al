# NOTE: Derived from .././blib/lib/Tk/Menubutton.pm.  Changes made here will be lost.
package Tk::Menubutton;

# Enter --
# This procedure is invoked when the mouse enters a menubutton
# widget. It activates the widget unless it is disabled. Note:
# this procedure is only invoked when mouse button 1 is *not* down.
# The procedure B1Enter is invoked if the button is down.
#
# Arguments:
# w - The name of the widget.
sub Enter
{
 my $w = shift;
 $Tk::inMenubutton->Leave if (defined $Tk::inMenubutton);
 $Tk::inMenubutton = $w;
 if ($w->cget("-state") ne "disabled")
  {
   $w->configure("-state","active")
  }
}

1;
