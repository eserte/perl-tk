# NOTE: Derived from .././blib/lib/Tk/Scale.pm.  Changes made here will be lost.
package Tk::Scale;

sub ButtonUp
{
 my ($w,$x,$y) = @_;
 $w->CancelRepeat();
 $w->EndDrag();
 $w->Activate($x,$y)
}

1;
