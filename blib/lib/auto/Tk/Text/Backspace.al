# NOTE: Derived from ../blib/lib/Tk/Text.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Text;

#line 309 "../blib/lib/Tk/Text.pm (autosplit into ../blib/lib/auto/Tk/Text/Backspace.al)"
sub Backspace
{
 my $w = shift;
 my $sel = Tk::catch { $w->tag('nextrange','sel','1.0','end') };
 if (defined $sel)
  {
   $w->delete('sel.first','sel.last')
  }
 elsif ($w->compare('insert',"!=",'1.0'))
  {
   $w->delete("insert-1c");
   $w->see('insert')
  }
}

# end of Tk::Text::Backspace
1;
