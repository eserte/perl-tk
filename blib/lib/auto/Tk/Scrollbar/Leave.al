# NOTE: Derived from ../blib/lib/Tk/Scrollbar.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Scrollbar;

#line 89 "../blib/lib/Tk/Scrollbar.pm (autosplit into ../blib/lib/auto/Tk/Scrollbar/Leave.al)"
sub Leave
{
 my $w = shift;
 if ($Tk::strictMotif)
  {
   $w->configure("-activebackground" => $activeBg) if (defined $activeBg) ;
  }
 $w->activate("");
}

# end of Tk::Scrollbar::Leave
1;
