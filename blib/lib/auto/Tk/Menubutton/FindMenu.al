# NOTE: Derived from .././blib/lib/Tk/Menubutton.pm.  Changes made here will be lost.
package Tk::Menubutton;

sub FindMenu
{
 my $child = shift;
 my $char = shift;
 my $ul = $child->cget("-underline");
 if (defined $ul && $ul >= 0 && $child->cget("-state") ne "disabled")
  {
   my $char2 = $child->cget("-text");
   $char2 = substr("\L$char2",$ul,1) if (defined $char2);
   if (!defined($char) || $char eq "" || (defined($char2) && "\l$char" eq $char2))
    {
     return $child;
    }
  }
 return undef;
}

1;
1;
