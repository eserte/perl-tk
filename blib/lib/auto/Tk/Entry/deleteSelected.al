# NOTE: Derived from .././blib/lib/Tk/Entry.pm.  Changes made here will be lost.
package Tk::Entry;

sub deleteSelected
{
 shift->delete("sel.first","sel.last")
}

1;
