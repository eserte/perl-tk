# NOTE: Derived from blib/lib/Tk/Frame.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Frame;

#line 245 "blib/lib/Tk/Frame.pm (autosplit into blib/lib/auto/Tk/Frame/packscrollbars.al)"
sub packscrollbars
{
 my ($cw) = @_;
 my $opt    = $cw->cget('-scrollbars');
 my $slice  = $cw->Subwidget('ysbslice');
 my $xsb    = $cw->Subwidget('xscrollbar');
 my $corner = $cw->Subwidget('corner');
 my $w      = $cw->Subwidget('scrolled');
 my $xside  = (($opt =~ /n/) ? 'top' : 'bottom');
 my $havex  = 0;
 my $havey  = 0;
 $opt =~ s/r//;
 $cw->{'pack_pending'} = 0;
 if (defined $slice)
  {
   my $reqy;
   my $ysb    = $cw->Subwidget('yscrollbar');
   if ($opt =~ /(o)?[we]/ && (($reqy = !defined($1)) || $ysb->Needed))
    {
     my $yside = (($opt =~ /w/) ? 'left' : 'right');  
     $slice->pack(-side => $yside, -fill => 'y',-before => $slice->{'before'});
     $havey = 1;
     if ($reqy)
      {
       $w->configure(-yscrollcommand => ['set', $ysb]);
      }
     else
      {
       $w->configure(-yscrollcommand => ['sbset', $cw, $ysb, \$cw->{'packysb'}]);
      }
    }
   else
    {
     $w->configure(-yscrollcommand => undef) unless $opt =~ s/[we]//;
     $slice->packForget;
    }
   $cw->{'packysb'} = $havey;
  }
 if (defined $xsb)
  {
   my $reqx;
   if ($opt =~ /(o)?[ns]/ && (($reqx = !defined($1)) || $xsb->Needed))
    {
     $xsb->pack(-side => $xside, -fill => 'x',-before => $xsb->{'before'});
     $havex = 1;
     if ($reqx)
      {
       $w->configure(-xscrollcommand => ['set', $xsb]);
      }
     else
      {
       $w->configure(-xscrollcommand => ['sbset', $cw, $xsb, \$cw->{'packxsb'}]);
      }
    }
   else
    {
     $w->configure(-xscrollcommand => undef) unless $opt =~ s/[ns]//;
     $xsb->packForget;
    }
   $cw->{'packxsb'} = $havex;
  }
 if (defined $corner)
  {
   if ($havex && $havey && defined $corner->{'before'})
    {
     my $anchor = $opt;
     $anchor =~ s/o//g;
     $corner->configure(-height => $xsb->ReqHeight);
     $corner->pack(-before => $corner->{'before'}, -side => $xside, 
                   -anchor => $anchor, -fill => 'x');
    }
   else
    {
     $corner->packForget;
    }
  }
}

# end of Tk::Frame::packscrollbars
1;
