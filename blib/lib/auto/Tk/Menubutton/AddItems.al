# NOTE: Derived from .././blib/lib/Tk/Menubutton.pm.  Changes made here will be lost.
package Tk::Menubutton;

sub AddItems
{
 shift->menu->AddItems(@_);
}

1;
