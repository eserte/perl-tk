# NOTE: Derived from ../blib/lib/Tk/Scrollbar.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Scrollbar;

#line 291 "../blib/lib/Tk/Scrollbar.pm (autosplit into ../blib/lib/auto/Tk/Scrollbar/EndDrag.al)"
# tkScrollEndDrag --
# This procedure is called to end an interactive drag of the slider.
# It scrolls the window if we're in jump mode, otherwise it does nothing.
#
# Arguments:
# w -		The scrollbar widget.
# x, y -	The mouse position at the end of the drag operation.

sub EndDrag
{
 my $w = shift;
 my $x = shift;
 my $y = shift;
 return unless defined($initMouse);
 if ($w->cget("-jump"))
  {
   $w->ScrlToPos($initPos + $w->fraction($x,$y) - $initMouse); 
  }
 undef $initMouse;
}

# end of Tk::Scrollbar::EndDrag
1;
