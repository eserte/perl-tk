# NOTE: Derived from .././blib/lib/Tk/Menubutton.pm.  Changes made here will be lost.
package Tk::Menubutton;

sub PostFirst
{
 my $w = shift;
 my $menu = $w->cget("-menu");
 $w->Post();
 $menu->FirstEntry() if (defined $menu);
}

1;
