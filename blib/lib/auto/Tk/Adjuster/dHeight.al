# NOTE: Derived from ./blib/lib/Tk/Adjuster.pm.  Changes made here will be lost.
package Tk::Adjuster;

sub dHeight
{
 my ($w,$dy,$sdy,$down) = @_;
 my $l = $w->{'lin'};
 if ($down && $w->cget('-delay'))
  {
   my $r = $w->{'sep'};
   $l->GeometryRequest($r->Width,1) unless $l->IsMapped;
   $l->MoveToplevelWindow($r->rootx,$r->rooty+$sdy);
   $l->MapWindow unless $l->IsMapped;
   $l->XRaiseWindow;
  }
 else
  {
   $l->UnmapWindow;
   my $s = $w->slave;
   $s->GeometryRequest($s->Width,$s->Height+$dy) if (defined $s);
  }
 $w->idletasks;
}

1;
