# NOTE: Derived from .././blib/lib/Tk/Listbox.pm.  Changes made here will be lost.
package Tk::Listbox;

sub SetList
{
 my $w = shift;
 $w->delete(0,"end");
 $w->insert("end",@_);
}

1;
