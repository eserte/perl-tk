# NOTE: Derived from ../blib/lib/Tk/Scrollbar.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Scrollbar;

#line 230 "../blib/lib/Tk/Scrollbar.pm (autosplit into ../blib/lib/auto/Tk/Scrollbar/StartDrag.al)"
# tkScrollStartDrag --
# This procedure is called to initiate a drag of the slider.  It just
# remembers the starting position of the slider.
#
# Arguments:
# w -		The scrollbar widget.
# x, y -	The mouse position at the start of the drag operation.

sub StartDrag
{my $w = shift;
 my $x = shift;
 my $y = shift;
 return unless (defined ($w->cget("-command")));
 $initMouse  = $w->fraction($x,$y);
 @initValues = $w->get();
 if (@initValues == 2)
  {
   $initPos = $initValues[0];
  }
 else
  {
   $initPos = $initValues[2] / $initValues[0];
  }
}

# end of Tk::Scrollbar::StartDrag
1;
