# NOTE: Derived from ../blib/lib/Tk/Scrollbar.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Scrollbar;

#line 76 "../blib/lib/Tk/Scrollbar.pm (autosplit into ../blib/lib/auto/Tk/Scrollbar/Enter.al)"
sub Enter
{
 my $w = shift;
 my $e = $w->XEvent;
 if ($Tk::strictMotif)
  {
   my $bg = $w->cget("-background");
   $activeBg = $w->cget("-activebackground");
   $w->configure("-activebackground" => $bg);
  }
 $w->activate($w->identify($e->x,$e->y));
}

# end of Tk::Scrollbar::Enter
1;
