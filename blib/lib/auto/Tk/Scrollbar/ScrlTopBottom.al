# NOTE: Derived from ../blib/lib/Tk/Scrollbar.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Scrollbar;

#line 398 "../blib/lib/Tk/Scrollbar.pm (autosplit into ../blib/lib/auto/Tk/Scrollbar/ScrlTopBottom.al)"
# tkScrlTopBottom
# Scroll to the top or bottom of the document, depending on the mouse
# position.
#
# Arguments:
# w -		The scrollbar widget.
# x, y -	Mouse coordinates within the widget.

sub ScrlTopBottom 
{
 my $w = shift;
 my $e = $w->XEvent;
 my $element = $w->identify($e->x,$e->y);
 return unless ($element);
 if ($element =~ /1$/)
  {
   $w->ScrlToPos(0);
  }
 elsif ($element =~ /2$/)
  {
   $w->ScrlToPos(1);
  }
}

1;
# end of Tk::Scrollbar::ScrlTopBottom
