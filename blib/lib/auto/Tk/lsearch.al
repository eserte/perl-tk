# NOTE: Derived from blib/lib/Tk.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk;

#line 681 "blib/lib/Tk.pm (autosplit into blib/lib/auto/Tk/lsearch.al)"
sub lsearch
{my $ar = shift;
 my $x  = shift;
 my $i;
 for ($i = 0; $i < scalar @$ar; $i++)
  {
   return $i if ($$ar[$i] eq $x);
  }
 return -1;
}

1;
# end of Tk::lsearch
