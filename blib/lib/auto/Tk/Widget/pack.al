# NOTE: Derived from ./blib/lib/Tk/Widget.pm.  Changes made here will be lost.
package Tk::Widget;

sub pack
{
 local $SIG{'__DIE__'} = \&Carp::croak;
 my $w = shift;
 if (@_ && $_[0] =~ /^(?:configure|forget|info|propagate|slaves)$/x)
  {
   $w->Tk::pack(@_);
  }
 else
  {
   # Two things going on here:
   # 1. Add configure on the front so that we can drop leading '-' 
   $w->Tk::pack('configure',@_);
   # 2. Return the widget rather than nothing
   return $w;
  }
}

1;
