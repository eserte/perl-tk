# Copyright (c) 1995-1998 Nick Ing-Simmons. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
package Tk::Toplevel; 
require Tk::Frame;
require Tk::Wm;
use AutoLoader;

use vars qw($VERSION @ISA);
$VERSION = '3.011'; # $Id: //depot/Tk8/Tk/Toplevel.pm#11$

@ISA = qw(Tk::Wm Tk::Frame);

Construct Tk::Widget 'Toplevel';

sub Tk_cmd { \&Tk::toplevel }

sub CreateOptions
{
 return (shift->SUPER::CreateOptions,'-screen','-use')
}

sub Populate
{
 my ($cw,$arg) = @_;
 $cw->SUPER::Populate($arg);
 $cw->ConfigSpecs('-title',['METHOD',undef,undef,$cw->class]);
}

sub Icon
{
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
   $icon->ConfigSpecs(DEFAULT => ['DESCENDANTS']);
   # Now do tail of InitObject
   $icon->ConfigDefault(\%args);
   # And configure that new would have done
   $top->iconwindow($icon);                
   $top->update;
   $lab->DisableButtonEvents;              
   $lab->update;
  }
 $icon->configure(%args);
 $icon->idletasks; # Let size request propogate
 $icon->geometry($icon->ReqWidth . "x" . $icon->ReqHeight); 
 $icon->update;    # Let attributes propogate
 $top->deiconify if ($state eq 'normal');
 $top->iconify   if ($state eq 'iconic');
}

1;
__END__



