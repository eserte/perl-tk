# NOTE: Derived from .././blib/lib/Tk/Text.pm.  Changes made here will be lost.
package Tk::Text;

sub Motion2
{
 my ($w,$x,$y) = @_;
 $Tk::mouseMoved = 1 if ($x != $Tk::x || $y != $Tk::y);
 $w->scan('dragto',$x,$y) if ($Tk::mouseMoved);
}

1;
