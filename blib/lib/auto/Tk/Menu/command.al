# NOTE: Derived from .././blib/lib/Tk/Menu.pm.  Changes made here will be lost.
package Tk::Menu;

sub command     { require Tk::Menu::Item; shift->Command(@_);     }
1;
