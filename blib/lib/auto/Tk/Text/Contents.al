# NOTE: Derived from ../blib/lib/Tk/Text.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Text;

#line 749 "../blib/lib/Tk/Text.pm (autosplit into ../blib/lib/auto/Tk/Text/Contents.al)"
sub Contents
{
 my $w = shift;
 if (@_)
  {
   $w->delete('1.0','end');
   $w->insert('end',shift);
  }
 else
  {
   return $w->get('1.0','end');
  }
}

# end of Tk::Text::Contents
1;
