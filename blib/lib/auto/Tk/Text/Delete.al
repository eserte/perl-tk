# NOTE: Derived from ../blib/lib/Tk/Text.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Text;

#line 324 "../blib/lib/Tk/Text.pm (autosplit into ../blib/lib/auto/Tk/Text/Delete.al)"
sub Delete
{
 my $w = shift;
 my $sel = Tk::catch { $w->tag('nextrange','sel','1.0','end') };
 if (defined $sel)
  {
   $w->delete("sel.first","sel.last")
  }
 else
  {
   $w->delete('insert');
   $w->see('insert')
  }
}

# end of Tk::Text::Delete
1;
