# NOTE: Derived from ./blib/lib/Tk/Widget.pm.  Changes made here will be lost.
package Tk::Widget;

sub propertyRoot
{
 my $w = shift;
 return $w->property(@_,'root');
}

1;
