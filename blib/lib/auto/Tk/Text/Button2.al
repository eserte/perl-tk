# NOTE: Derived from .././blib/lib/Tk/Text.pm.  Changes made here will be lost.
package Tk::Text;

sub Button2
{
 my ($w,$x,$y) = @_;
 $w->scan('mark',$x,$y);
 $Tk::x = $x;
 $Tk::y = $y;
 $Tk::mouseMoved = 0;
}

1;
