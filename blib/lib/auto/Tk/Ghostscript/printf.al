# NOTE: Derived from .././blib/lib/Tk/Ghostscript.pm.  Changes made here will be lost.
package Tk::Ghostscript;

sub printf
{my $w = shift;
 my $fmt = shift;
 $w->Postscript(sprintf($fmt,@_));
}

1;
