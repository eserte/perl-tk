# NOTE: Derived from ./blib/lib/Tk/Adjuster.pm.  Changes made here will be lost.
package Tk::Adjuster;

sub dWidth
{
 my ($w,$dx,$sdx,$down) = @_;
 my $l = $w->{'lin'};
 if ($down && $w->cget('-delay'))
  {
   my $r = $w->{'sep'};
   $l->GeometryRequest(1,$r->Height) unless $l->IsMapped;
   $l->MoveToplevelWindow($sdx+$r->rootx,$r->rooty);
   $l->MapWindow unless ($l->IsMapped);
   $l->XRaiseWindow;
  }
 else
  {
   $l->UnmapWindow;
   my $s = $w->slave;
   $s->GeometryRequest($s->Width+$dx,$s->Height) if (defined $s);
  }
 $w->idletasks;
}

1;
