# NOTE: Derived from .././blib/lib/Tk/Web.pm.  Changes made here will be lost.
package Tk::Web;

sub Forward
{
 my ($w) = @_;
 if (@{$w->{FORWARD}})
  {
   unshift(@{$w->{BACK}},$w->context);
   $w->context(shift(@{$w->{FORWARD}}));
  }
 $w->break;
}

1;
