# NOTE: Derived from ./blib/lib/Tk/Wm.pm.  Changes made here will be lost.
package Tk::Wm;

sub iconposition
{
 my $w = shift;
 return $w->wm('iconposition',$1,$2) if (@_ == 1 && $_[0] =~ /^(\d+),(\d+)$/); 
 $w->wm('iconposition',@_);
}

1;
