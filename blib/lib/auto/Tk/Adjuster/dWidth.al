# NOTE: Derived from blib/lib/Tk/Adjuster.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Adjuster;

#line 235 "blib/lib/Tk/Adjuster.pm (autosplit into blib/lib/auto/Tk/Adjuster/dWidth.al)"
sub dWidth
{
 my ($w,$dx,$sdx,$down) = @_;
 my $l = $w->{'lin'};
 if ($down && $w->cget('-delay'))
  {
   my $r = $w->{'sep'};
   $l->GeometryRequest(1,$r->Height) unless $l->IsMapped;

   my $base = $w->Parent;
   if ($sdx+$r->rootx >= $base->rootx
       && $sdx+$r->rootx < $base->rootx + $base->width)
    {
     # avoid drag hanging
     unless ($sdx == $w->{lastsd})
      {
       $l->MoveToplevelWindow($sdx+$r->rootx,$r->rooty);
       $w->{lastsd} = $sdx;
      }

     $l->MapWindow unless ($l->IsMapped);
     $l->XRaiseWindow;
    }
   # Dragged line out of parent frame the first time...
   elsif ($l->IsMapped)
    {
     $l->UnmapWindow;
    }
  }
 else
  {
   $l->UnmapWindow;
   my $s = $w->slave;
   $s->GeometryRequest($s->Width+$dx,$s->Height) if (defined $s);
   $w->XSync(1);
  }
 $w->idletasks;
}

# end of Tk::Adjuster::dWidth
1;
