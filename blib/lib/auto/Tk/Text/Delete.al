# NOTE: Derived from .././blib/lib/Tk/Text.pm.  Changes made here will be lost.
package Tk::Text;

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

1;
