# NOTE: Derived from blib/lib/Tk/Wm.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Wm;

#line 58 "blib/lib/Tk/Wm.pm (autosplit into blib/lib/auto/Tk/Wm/Post.al)"
sub Post
{
 my ($w,$X,$Y) = @_;
 $X = int($X);
 $Y = int($Y);
 $w->positionfrom('user');
 # $w->geometry("+$X+$Y");
 $w->MoveToplevelWindow($X,$Y);
 $w->deiconify;
 $w->raise;
}

# end of Tk::Wm::Post
1;
