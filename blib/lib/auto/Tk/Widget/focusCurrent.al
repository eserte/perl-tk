# NOTE: Derived from ./blib/lib/Tk/Widget.pm.  Changes made here will be lost.
package Tk::Widget;

sub focusCurrent
{
 my ($w) = @_;
 $w->Tk::focus('-displayof'); 
}

1;
