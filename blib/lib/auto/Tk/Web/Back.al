# NOTE: Derived from .././blib/lib/Tk/Web.pm.  Changes made here will be lost.
package Tk::Web;

sub Back
{
 my ($w) = @_;
 if (@{$w->{BACK}})
  {
   unshift(@{$w->{FORWARD}},$w->context);
   $w->context(pop(@{$w->{BACK}}));
  }
 $w->break;
}

1;
