# NOTE: Derived from ./blib/lib/Tk/Widget.pm.  Changes made here will be lost.
package Tk::Widget;

sub Popwidget
{
 my ($ew,$method,$w,@args) = @_;
 $w->{'_EventWidget_'} = $ew;
 $w->$method(@args);
}

1;
