# NOTE: Derived from .././blib/lib/Tk/Menubutton.pm.  Changes made here will be lost.
package Tk::Menubutton;

sub ButtonDown
{my $w = shift;
 my $Ev = $w->XEvent;
 $Tk::inMenubutton->Post($Ev->X,$Ev->Y) if (defined $Tk::inMenubutton);
}

1;
