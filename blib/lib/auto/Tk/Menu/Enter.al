# NOTE: Derived from .././blib/lib/Tk/Menu.pm.  Changes made here will be lost.
package Tk::Menu;

sub Enter
{
 my $w = shift; 
 $Tk::window = $w; 
 $w->focus();
}

1;
