# NOTE: Derived from ./blib/lib/Tk.pm.  Changes made here will be lost.
package Tk;

sub Exists
{my $w = shift;
 return defined($w) && ref($w) && $w->IsWidget && $w->exists;
}

1;
