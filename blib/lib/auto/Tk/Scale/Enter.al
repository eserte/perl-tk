# NOTE: Derived from ../blib/lib/Tk/Scale.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Scale;

#line 117 "../blib/lib/Tk/Scale.pm (autosplit into ../blib/lib/auto/Tk/Scale/Enter.al)"
sub Enter
{
 my ($w,$x,$y) = @_;
 if ($Tk::strictMotif)
  {
   $w->{'activeBg'} = $w->cget("-activebackground");
   $w->configure("-activebackground",$w->cget("-background"));
  }
 $w->Activate($x,$y);
}

# end of Tk::Scale::Enter
1;
