# NOTE: Derived from .././blib/lib/Tk/Scale.pm.  Changes made here will be lost.
package Tk::Scale;

# ButtonDown --
# This procedure is invoked when a button is pressed in a scale. It
# takes different actions depending on where the button was pressed.
#
# Arguments:
# w - The scale widget.
# x, y - Mouse coordinates of button press.
sub ButtonDown
{
 my $w = shift;
 my $x = shift;
 my $y = shift;
 $Tk::dragging = 0;
 $el = $w->identify($x,$y);
 return unless ($el);
 if ($el eq "trough1")
  {
   $w->Increment("up","little","initial")
  }
 elsif ($el eq "trough2")
  {
   $w->Increment("down","little","initial")
  }
 elsif ($el eq "slider")
  {
   $Tk::dragging = 1;
   my @coords = $w->coords();
   $Tk::deltaX = $x-$coords[0];
   $Tk::deltaY = $y-$coords[1];
  }
}

1;
