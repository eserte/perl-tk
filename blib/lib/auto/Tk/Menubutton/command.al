# NOTE: Derived from .././blib/lib/Tk/Menubutton.pm.  Changes made here will be lost.
package Tk::Menubutton;

sub command     { require Tk::Menu::Item; shift->menu->Command(@_);     }
1;
