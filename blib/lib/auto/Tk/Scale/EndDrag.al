# NOTE: Derived from .././blib/lib/Tk/Scale.pm.  Changes made here will be lost.
package Tk::Scale;

# EndDrag --
# This procedure is called to end an interactive drag of the
# slider.  It just marks the drag as over.
# Arguments:
# w - The scale widget.
sub EndDrag
{
 my $w = shift;
 if (!$Tk::dragging)
  {
   return;
  }
 $Tk::dragging = 0;
}

1;
