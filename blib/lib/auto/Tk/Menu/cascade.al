# NOTE: Derived from .././blib/lib/Tk/Menu.pm.  Changes made here will be lost.
package Tk::Menu;

sub cascade     { require Tk::Menu::Item; shift->Cascade(@_);     }
1;
