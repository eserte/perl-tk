# NOTE: Derived from .././blib/lib/Tk/Menubutton.pm.  Changes made here will be lost.
package Tk::Menubutton;

sub entryconfigure
{
 shift->menu->entryconfigure(@_);
}

1;
