# NOTE: Derived from ./blib/lib/Tk/Wm.pm.  Changes made here will be lost.
package Tk::Wm;

sub Post
{
 my ($w,$X,$Y) = @_;
 $X = int($X);
 $Y = int($Y);
 $w->positionfrom('program');
 $w->geometry("+$X+$Y");
 $w->deiconify;
 $w->raise;
}

1;
