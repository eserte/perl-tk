# NOTE: Derived from ./blib/lib/Tk.pm.  Changes made here will be lost.
package Tk;

sub interps
{
 my $w = shift;
 return $w->winfo('interps','-displayof');
}

1;
