# NOTE: Derived from .././blib/lib/Tk/Menu.pm.  Changes made here will be lost.
package Tk::Menu;

# Some convenience methods 

sub separator   { require Tk::Menu::Item; shift->Separator(@_);   }
1;
