# NOTE: Derived from ../blib/lib/Tk/Text.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Text;

#line 200 "../blib/lib/Tk/Text.pm (autosplit into ../blib/lib/auto/Tk/Text/Motion2.al)"
sub Motion2
{
 my ($w,$x,$y) = @_;
 $Tk::mouseMoved = 1 if ($x != $Tk::x || $y != $Tk::y);
 $w->scan('dragto',$x,$y) if ($Tk::mouseMoved);
}

# end of Tk::Text::Motion2
1;
