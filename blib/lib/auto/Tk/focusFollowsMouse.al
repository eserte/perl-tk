# NOTE: Derived from ./blib/lib/Tk.pm.  Changes made here will be lost.
package Tk;

sub focusFollowsMouse
{
 my $widget = shift;
 $widget->bind('all',"EnterFocus");
}

1;
