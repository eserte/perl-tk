# NOTE: Derived from ./blib/lib/Tk/Widget.pm.  Changes made here will be lost.
package Tk::Widget;

sub waitVariable
{
 my ($w) = shift;
 $w->tkwait('variable',@_);
}

1;
