package Tk::Toplevel; 
require Tk::Frame;
require Tk::Wm;
require Tk::Pretty;
use AutoLoader;
@ISA = qw(Tk::Wm Tk::Frame);

Tk::Widget->Construct('Toplevel');

sub Tk_cmd { \&Tk::toplevel }

sub CreateArgs
{
 my ($package,$parent,$args) = @_;
 my @result = $package->SUPER::CreateArgs($parent,$args);
 my $screen = delete $args->{-screen};                     
 push(@result, '-screen' => $screen) if (defined $screen);
 return @result;
}

sub Populate
{
 my ($cw,$arg) = @_;
 $cw->SUPER::Populate($arg);
 $cw->ConfigSpecs('-title',[METHOD,undef,undef,$cw->class]);
}

1;
__END__

sub Icon
{
 require Tk::Toplevel;
 my ($top,%args) = @_;
 my $icon  = $top->iconwindow;
 my $state = $top->state;                 
 if ($state ne 'withdrawn')
  {
   $top->withdraw; 
   $top->update;    # Let attributes propogate
  }
 unless (defined $icon)
  {
   $icon  = Tk::Toplevel->new($top,'-borderwidth' => 0,'-class'=>'Icon');
   $icon->withdraw;                        
   # Fake Populate 
   my $lab  = $icon->Component('Label' => 'icon');
   $lab->pack('-expand'=>1,'-fill' => 'both');
   $lab->DisableButtonEvents;              
   $icon->DisableButtonEvents;             
   $icon->ConfigSpecs(DEFAULT => ['DESCENDANTS']);
   # Now do tail of InitObject
   $icon->ConfigDefault(\%args);
   # And configure that new would have done
   $top->iconwindow($icon);                
  }
 $icon->configure(%args);
 $icon->idletasks; # Let size request propogate
 $icon->geometry($icon->ReqWidth . "x" . $icon->ReqHeight); 
 $icon->update;    # Let attributes propogate
 $top->deiconify if ($state eq 'normal');
 $top->iconify   if ($state eq 'iconic');
}



