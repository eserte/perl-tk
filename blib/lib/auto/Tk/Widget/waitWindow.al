# NOTE: Derived from ./blib/lib/Tk/Widget.pm.  Changes made here will be lost.
package Tk::Widget;

sub waitWindow
{
 my ($w) = shift;
 $w->tkwait('window',$w);
}

1;
