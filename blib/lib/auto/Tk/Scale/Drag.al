# NOTE: Derived from .././blib/lib/Tk/Scale.pm.  Changes made here will be lost.
package Tk::Scale;

# Drag --
# This procedure is called when the mouse is dragged with
# mouse button 1 down. If the drag started inside the slider
# (i.e. the scale is active) then the scale's value is adjusted
# to reflect the mouse's position.
#
# Arguments:
# w - The scale widget.
# x, y - Mouse coordinates.
sub Drag
{
 my $w = shift;
 my $x = shift;
 my $y = shift;
 if (!$Tk::dragging)
  {
   return;
  }
 $w->set($w->get($x-$Tk::deltaX,$y-$Tk::deltaY))
}

1;
