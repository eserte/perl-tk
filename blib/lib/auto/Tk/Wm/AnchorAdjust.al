# NOTE: Derived from ./blib/lib/Tk/Wm.pm.  Changes made here will be lost.
package Tk::Wm;

sub AnchorAdjust
{
 my ($anchor,$X,$Y,$w,$h) = @_;
 $anchor = 'c' unless (defined $anchor);
 $Y += ($anchor =~ /s/) ? $h : ($anchor =~ /n/) ? 0 : $h/2;
 $X += ($anchor =~ /e/) ? $w : ($anchor =~ /w/) ? 0 : $w/2;
 return ($X,$Y);
}

1;
