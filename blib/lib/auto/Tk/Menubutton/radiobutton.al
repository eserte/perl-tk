# NOTE: Derived from .././blib/lib/Tk/Menubutton.pm.  Changes made here will be lost.
package Tk::Menubutton;

sub radiobutton { require Tk::Menu::Item; shift->menu->Radiobutton(@_); }

1;
