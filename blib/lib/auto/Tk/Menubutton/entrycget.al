# NOTE: Derived from .././blib/lib/Tk/Menubutton.pm.  Changes made here will be lost.
package Tk::Menubutton;

sub entrycget
{
 shift->menu->entrycget(@_);
}

1;
