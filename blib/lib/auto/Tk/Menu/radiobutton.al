# NOTE: Derived from .././blib/lib/Tk/Menu.pm.  Changes made here will be lost.
package Tk::Menu;

sub radiobutton { require Tk::Menu::Item; shift->Radiobutton(@_); }

1; 
1;
