# NOTE: Derived from ./blib/lib/Tk/Widget.pm.  Changes made here will be lost.
package Tk::Widget;

sub AddBindTag
{
 my ($w,$tag) = @_;
 my $t;
 my @tags = $w->bindtags;
 foreach $t (@tags)
  {
   return if $t eq $tag;
  }
 $w->bindtags([@tags,$tag]);
}

1;
