# NOTE: Derived from ../blib/lib/Tk/Text.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Text;

#line 446 "../blib/lib/Tk/Text.pm (autosplit into ../blib/lib/auto/Tk/Text/AutoScan.al)"
# AutoScan --
# This procedure is invoked when the mouse leaves a text window
# with button 1 down. It scrolls the window up, down, left, or right,
# depending on where the mouse is (this information was saved in
# tkPriv(x) and tkPriv(y)), and reschedules itself as an 'after'
# command so that the window continues to scroll until the mouse
# moves back into the window or the mouse button is released.
#
# Arguments:
# w - The text window.
sub AutoScan
{
 my $w = shift;
 if ($Tk::y >= $w->height)
  {
   $w->yview('scroll',2,'units')
  }
 elsif ($Tk::y < 0)
  {
   $w->yview('scroll',-2,'units')
  }
 elsif ($Tk::x >= $w->width)
  {
   $w->xview('scroll',2,'units')
  }
 elsif ($Tk::x < 0)
  {
   $w->xview('scroll',-2,'units')
  }
 else
  {
   return;
  }
 $w->SelectTo("@" . $Tk::x . ",". $Tk::y);
 $w->RepeatId($w->after(50,"AutoScan",$w));
}

# end of Tk::Text::AutoScan
1;
