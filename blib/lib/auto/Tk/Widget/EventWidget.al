# NOTE: Derived from ./blib/lib/Tk/Widget.pm.  Changes made here will be lost.
package Tk::Widget;

sub EventWidget
{
 my ($w) = @_;
 return $w->{'_EventWidget_'};
}

1;
