# NOTE: Derived from ./blib/lib/Tk/Widget.pm.  Changes made here will be lost.
package Tk::Widget;

sub waitVisibility
{
 my ($w) = shift;
 $w->tkwait('visibility',$w);
}

1;
