# NOTE: Derived from .././blib/lib/Tk/Menubutton.pm.  Changes made here will be lost.
package Tk::Menubutton;

sub cascade     { require Tk::Menu::Item; shift->menu->Cascade(@_);     }
1;
