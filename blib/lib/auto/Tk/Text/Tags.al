# NOTE: Derived from .././blib/lib/Tk/Text.pm.  Changes made here will be lost.
package Tk::Text;

sub Tags
{
 my $w = shift;
 my $name;
 my @result = ();
 foreach $name ($w->tagNames(@_))
  {
   push(@result,$w->Tag($name));
  }
 return @result;
}

1;
