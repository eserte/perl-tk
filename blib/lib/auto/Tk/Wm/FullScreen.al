# NOTE: Derived from ./blib/lib/Tk/Wm.pm.  Changes made here will be lost.
package Tk::Wm;

sub FullScreen
{
 my $w = shift;
 my $over = (@_) ? shift : 0;
 $w->GeometryRequest($w->screenwidth,$w->screenheight);
 $w->overrideredirect($over);
 $w->Post(0,0);
}

1;
