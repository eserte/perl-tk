# NOTE: Derived from ../blib/lib/Tk/Text.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Text;

#line 207 "../blib/lib/Tk/Text.pm (autosplit into ../blib/lib/auto/Tk/Text/Button2.al)"
sub Button2
{
 my ($w,$x,$y) = @_;
 $w->scan('mark',$x,$y);
 $Tk::x = $x;
 $Tk::y = $y;
 $Tk::mouseMoved = 0;
}

# end of Tk::Text::Button2
1;
