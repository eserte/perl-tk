# NOTE: Derived from ./blib/lib/Tk/Widget.pm.  Changes made here will be lost.
package Tk::Widget;

sub grid
{
 local $SIG{'__DIE__'} = \&Carp::croak;
 my $w = shift;
 if (@_ && $_[0] =~ /^(?:bbox|columnconfigure|configure|forget|info|location|propagate|rowconfigure|size|slaves)$/x)
  {
   my $opt = shift;
   Tk::grid($opt,$w,@_);
  }
 else
  {
   # Two things going on here:
   # 1. Add configure on the front so that we can drop leading '-' 
   Tk::grid('configure',$w,@_);
   # 2. Return the widget rather than nothing
   return $w;
  }
}

1;
