# NOTE: Derived from .././blib/lib/Tk/Menu.pm.  Changes made here will be lost.
package Tk::Menu;

sub checkbutton { require Tk::Menu::Item; shift->Checkbutton(@_); }
1;
