# NOTE: Derived from blib/lib/Tk/Adjuster.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Adjuster;

#line 274 "blib/lib/Tk/Adjuster.pm (autosplit into blib/lib/auto/Tk/Adjuster/dHeight.al)"
sub dHeight
{
 my ($w,$dy,$sdy,$down) = @_;
 my $l = $w->{'lin'};
 if ($down && $w->cget('-delay'))
  {
   my $r = $w->{'sep'};
   $l->GeometryRequest($r->Width,1) unless $l->IsMapped;

   my $base = $w->Parent;
   if ($sdy+$r->rooty >= $base->rooty
       && $sdy+$r->rooty < $base->rooty + $base->height)
    {
     # avoid drag hanging
     unless ($sdy == $w->{lastsd})
      {
       $l->MoveToplevelWindow($r->rootx,$sdy+$r->rooty);
       $w->{lastsd} = $sdy;
      }

     $l->MapWindow unless $l->IsMapped;
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
   $s->GeometryRequest($s->Width,$s->Height+$dy) if (defined $s);
   $w->XSync(1);
  }
 $w->idletasks;
}

1;
# end of Tk::Adjuster::dHeight
