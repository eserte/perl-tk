# NOTE: Derived from .././blib/lib/Tk/Text.pm.  Changes made here will be lost.
package Tk::Text;

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

1;
