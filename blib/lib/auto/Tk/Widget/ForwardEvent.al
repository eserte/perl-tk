# NOTE: Derived from ./blib/lib/Tk/Widget.pm.  Changes made here will be lost.
package Tk::Widget;

sub ForwardEvent
{
 my $self = shift;
 my $to   = shift;
 $to->PassEvent($self->XEvent);
}

1;
