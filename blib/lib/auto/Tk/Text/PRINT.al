# NOTE: Derived from ../blib/lib/Tk/Text.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Text;

#line 814 "../blib/lib/Tk/Text.pm (autosplit into ../blib/lib/auto/Tk/Text/PRINT.al)"
sub PRINT
{
 my $w = shift;
 while (@_)
  {
   $w->insert('end',shift);
  }
}

# end of Tk::Text::PRINT
1;
