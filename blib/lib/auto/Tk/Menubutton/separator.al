# NOTE: Derived from .././blib/lib/Tk/Menubutton.pm.  Changes made here will be lost.
package Tk::Menubutton;

sub separator   { require Tk::Menu::Item; shift->menu->Separator(@_);   }
1;
