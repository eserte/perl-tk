# NOTE: Derived from .././blib/lib/Tk/Ghostscript.pm.  Changes made here will be lost.
package Tk::Ghostscript;

sub PAGE
{
 my $w = shift;
 my $e = $w->XEvent;
 my ($m,$d) = unpack('LL',$e->A);
 $w->{'mwin'} = $m;
}

1;
