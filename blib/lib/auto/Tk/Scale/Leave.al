# NOTE: Derived from ../blib/lib/Tk/Scale.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Scale;

#line 110 "../blib/lib/Tk/Scale.pm (autosplit into ../blib/lib/auto/Tk/Scale/Leave.al)"
sub Leave
{
 my ($w) = @_;
 $w->configure("-activebackground",$w->{'activeBg'}) if ($Tk::strictMotif);
 $w->configure("-state","normal")  if ($w->cget("-state") eq "active");
}

# end of Tk::Scale::Leave
1;
