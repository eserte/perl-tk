# NOTE: Derived from ./blib/lib/Tk/Widget.pm.  Changes made here will be lost.
package Tk::Widget;

sub PrintConfig
{
 require Tk::Pretty;
 my ($w) = (@_);
 my $c;
 foreach $c ($w->configure)
  {
   print Tk::Pretty::Pretty(@$c),"\n";
  }
} 

1;
