# NOTE: Derived from .././blib/lib/Tk/Text.pm.  Changes made here will be lost.
package Tk::Text;

sub TIEHANDLE
{
 my ($class,$obj) = @_;
 return $obj;
}

1;
