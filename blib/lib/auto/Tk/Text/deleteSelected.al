# NOTE: Derived from .././blib/lib/Tk/Text.pm.  Changes made here will be lost.
package Tk::Text;

sub deleteSelected
{
 shift->delete("sel.first","sel.last")
}

1;
