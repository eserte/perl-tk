# NOTE: Derived from ./blib/lib/Tk/Frame.pm.  Changes made here will be lost.
package Tk::Frame;

sub labelPack
{
 my ($cw,$val) = @_;
 my $w = $cw->Subwidget('label');
 my @result = ();
 if (@_ > 1)
  {
   if (defined($w) && !defined($val))
    {
     $w->packForget;
    }
   elsif (defined($val) && !defined ($w))
    {
     require Tk::Label;
     $w = Tk::Label->new($cw,-textvariable => $cw->labelVariable);
     $cw->Advertise('label' => $w); 
     $cw->ConfigDelegate('label',qw(text textvariable));
    }
   if (defined($val) && defined($w))
    {
     my %pack = @$val;
     unless (exists $pack{-side})
      {
       $pack{-side} = 'top' unless (exists $pack{-side});
      }
     unless (exists $pack{-fill})
      {
       $pack{-fill} = 'x' if ($pack{-side} =~ /(top|bottom)/);
       $pack{-fill} = 'y' if ($pack{-side} =~ /(left|right)/);
      }
     unless (exists($pack{'-before'}) || exists($pack{'-after'}))
      {
       my $before = ($cw->packSlaves)[0];
       $pack{'-before'} = $before if (defined $before);
      }
     $w->pack(%pack);
    }
  }
 @result = $w->packInfo if (defined $w);
 return (wantarray) ? @result : \@result;
}

1;
