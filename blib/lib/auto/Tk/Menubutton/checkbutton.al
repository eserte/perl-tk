# NOTE: Derived from .././blib/lib/Tk/Menubutton.pm.  Changes made here will be lost.
package Tk::Menubutton;

sub checkbutton { require Tk::Menu::Item; shift->menu->Checkbutton(@_); }
1;
