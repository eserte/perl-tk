# NOTE: Derived from blib/lib/Tk/Wm.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Wm;

#line 70 "blib/lib/Tk/Wm.pm (autosplit into blib/lib/auto/Tk/Wm/AnchorAdjust.al)"
sub AnchorAdjust
{
 my ($anchor,$X,$Y,$w,$h) = @_;
 $anchor = 'c' unless (defined $anchor);
 $Y += ($anchor =~ /s/) ? $h : ($anchor =~ /n/) ? 0 : $h/2;
 $X += ($anchor =~ /e/) ? $w : ($anchor =~ /w/) ? 0 : $w/2;
 return ($X,$Y);
}

# end of Tk::Wm::AnchorAdjust
1;
