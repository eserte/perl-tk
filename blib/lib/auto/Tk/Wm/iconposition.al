# NOTE: Derived from blib/lib/Tk/Wm.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Wm;

#line 136 "blib/lib/Tk/Wm.pm (autosplit into blib/lib/auto/Tk/Wm/iconposition.al)"
sub iconposition
{
 my $w = shift;
 return $w->wm('iconposition',$1,$2) if (@_ == 1 && $_[0] =~ /^(\d+),(\d+)$/); 
 $w->wm('iconposition',@_);
}

1;
# end of Tk::Wm::iconposition
