# NOTE: Derived from ./blib/lib/Tk.pm.  Changes made here will be lost.
package Tk;

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
