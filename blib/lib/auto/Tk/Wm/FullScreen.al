# NOTE: Derived from blib/lib/Tk/Wm.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Wm;

#line 115 "blib/lib/Tk/Wm.pm (autosplit into blib/lib/auto/Tk/Wm/FullScreen.al)"
sub FullScreen
{
 my $w = shift;
 my $over = (@_) ? shift : 0;
 my $width  = $w->screenwidth;
 my $height = $w->screenheight;
 $w->GeometryRequest($width,$height);
 $w->overrideredirect($over & 1);
 $w->Post(0,0);
 $w->update;
 if ($over & 2)
  {
   my $x = $w->rootx;
   my $y = $w->rooty;
   $width -= 2*$x;
   $height -= $x + $y;
   $w->GeometryRequest($width,$height);
   $w->update;
  }
}

# end of Tk::Wm::FullScreen
1;
