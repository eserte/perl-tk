# NOTE: Derived from .././blib/lib/Tk/Menu.pm.  Changes made here will be lost.
package Tk::Menu;

sub typeIS
{my $w = shift;
 my $type = $w->type(shift);
 return defined $type && $type eq shift;
}

1;
