package Tk::Toplevel; 
require Tk::Frame;
require Tk::Wm;
use AutoLoader;
@ISA = qw(Tk::Wm Tk::Frame);

Tk::Widget->Construct('Toplevel');

sub Tk_cmd { \&Tk::toplevel }

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

sub SetBindtags
{
 my ($obj) = @_;
 $obj->bindtags([ref($obj),$obj,'all']);
}


1;

__END__

sub Populate
{
 my ($cw,$arg) = @_;
 $cw->ConfigSpecs('-title',[METHOD,undef,undef,$cw->class],
                  '-overanchor' => ['PASSIVE',undef,undef,undef],
                  '-popanchor'  => ['PASSIVE',undef,undef,undef],
                  '-popover'    => ['PASSIVE',undef,undef,undef] 
                 );
}



