# NOTE: Derived from ../blib/lib/Tk/Scale.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Scale;

#line 128 "../blib/lib/Tk/Scale.pm (autosplit into ../blib/lib/auto/Tk/Scale/ButtonUp.al)"
sub ButtonUp
{
 my ($w,$x,$y) = @_;
 $w->CancelRepeat();
 $w->EndDrag();
 $w->Activate($x,$y)
}

# end of Tk::Scale::ButtonUp
1;
