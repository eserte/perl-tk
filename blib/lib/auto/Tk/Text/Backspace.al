# NOTE: Derived from .././blib/lib/Tk/Text.pm.  Changes made here will be lost.
package Tk::Text;

sub Backspace
{
 my $w = shift;
 my $sel = Tk::catch { $w->tag('nextrange','sel','1.0','end') };
 if (defined $sel)
  {
   $w->delete("sel.first","sel.last")
  }
 elsif ($w->compare('insert',"!=",'1.0'))
  {
   $w->delete("insert-1c");
   $w->see('insert')
  }
}

1;
