# NOTE: Derived from ./blib/lib/Tk/Widget.pm.  Changes made here will be lost.
package Tk::Widget;

sub ScrlListbox
{
 my $parent = shift; 
 return $parent->Scrolled('Listbox',-scrollbars => 'w', @_);
}

1;
