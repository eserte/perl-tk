# NOTE: Derived from .././blib/lib/Tk/Text.pm.  Changes made here will be lost.
package Tk::Text;

sub PRINT
{
 my $w = shift;
 while (@_)
  {
   $w->insert('end',shift);
  }
}

1;
