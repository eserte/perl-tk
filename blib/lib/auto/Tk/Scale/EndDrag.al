# NOTE: Derived from ../blib/lib/Tk/Scale.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Scale;

#line 193 "../blib/lib/Tk/Scale.pm (autosplit into ../blib/lib/auto/Tk/Scale/EndDrag.al)"
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

# end of Tk::Scale::EndDrag
1;
