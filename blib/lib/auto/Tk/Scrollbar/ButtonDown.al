# NOTE: Derived from ../blib/lib/Tk/Scrollbar.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Scrollbar;

#line 115 "../blib/lib/Tk/Scrollbar.pm (autosplit into ../blib/lib/auto/Tk/Scrollbar/ButtonDown.al)"
# tkScrollButtonDown --
# This procedure is invoked when a button is pressed in a scrollbar.
# It changes the way the scrollbar is displayed and takes actions
# depending on where the mouse is.
#
# Arguments:
# w -		The scrollbar widget.
# x, y -	Mouse coordinates.

sub ButtonDown 
{my $w = shift;
 my $e = $w->XEvent;
 my $element = $w->identify($e->x,$e->y);
 $w->configure("-activerelief" => "sunken");
 if ($e->b == 1 and
     (defined($element) && $element eq "slider"))
  {
   $w->StartDrag($e->x,$e->y);
  }
 elsif ($e->b == 2 and
	(defined($element) && $element =~ /^(trough[12]|slider)$/o))
  {
	my $pos = $w->fraction($e->x, $e->y);
	my($head, $tail) = $w->get;
	my $len = $tail - $head;
		 
	$head = $pos - $len/2;
	$tail = $pos + $len/2;
	if ($head < 0) {
		$head = 0;
		$tail = $len;
	}
	elsif ($tail > 1) {
		$head = 1 - $len;
		$tail = 1;
	}
	$w->ScrlToPos($head);
	$w->set($head, $tail);

	$w->StartDrag($e->x,$e->y);
   }
 else
  {
   $w->Select($element,"initial");
  }
}

# end of Tk::Scrollbar::ButtonDown
1;
