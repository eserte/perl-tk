# NOTE: Derived from .././blib/lib/Tk/Text.pm.  Changes made here will be lost.
package Tk::Text;

sub Destroy
{
 my $w = shift;
 delete $w->{_Tags_};
}

1;
