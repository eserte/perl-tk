# Conversion from Tk4.0 button.tcl competed.
#
# Copyright (c) 1992-1994 The Regents of the University of California.
# Copyright (c) 1994 Sun Microsystems, Inc.
# Copyright (c) 1995-1997 Nick Ing-Simmons. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself, subject 
# to additional disclaimer in license.terms due to partial
# derivation from Tk4.0 sources.

package Tk::Button;  
use AutoLoader;
@ISA = qw(Tk::Widget);

use strict;
use vars qw($buttonWindow $relief);

sub Tk_cmd { \&Tk::button }

Construct Tk::Widget 'Button';

sub ClassInit
{
 my ($class,$mw) = @_;
 $mw->bind($class,'<Enter>', 'Enter');
 $mw->bind($class,'<Leave>', 'Leave');
 $mw->bind($class,'<1>', 'butDown');
 $mw->bind($class,'<ButtonRelease-1>', 'butUp');
 $mw->bind($class,'<space>', 'Invoke');
 return $class;
}

# tkButtonEnter --
# The procedure below is invoked when the mouse pointer enters a
# button widget.  It records the button we're in and changes the
# state of the button to active unless the button is disabled.
#
# Arguments:
# w -		The name of the widget.

sub Enter
{
 my $w = shift;
 my $E = shift;
 if ($w->cget("-state") ne "disabled")
  {
   $w->configure("-state" => "active");
   $w->configure("-state" => "active", "-relief" => "sunken") if (defined($buttonWindow) && $w == $buttonWindow)
  }
 $Tk::window = $w;
}

# tkButtonLeave --
# The procedure below is invoked when the mouse pointer leaves a
# button widget.  It changes the state of the button back to
# inactive.  If we're leaving the button window with a mouse button
# pressed (tkPriv(buttonWindow) == $w), restore the relief of the
# button too.
#
# Arguments:
# w -		The name of the widget.
sub Leave
{
 my $w = shift;
 $w->configure("-state"=>"normal") if ($w->cget("-state") ne "disabled");
 $w->configure("-relief" => $relief) if (defined($buttonWindow) && $w == $buttonWindow);
 undef $Tk::window;
}

# tkButtonDown --
# The procedure below is invoked when the mouse button is pressed in
# a button widget.  It records the fact that the mouse is in the button,
# saves the button's relief so it can be restored later, and changes
# the relief to sunken.
#
# Arguments:
# w -		The name of the widget.
sub butDown
{
 my $w = shift;
 $relief = $w->cget("-relief");
 if ($w->cget("-state") ne "disabled")
  {
   $buttonWindow = $w;
   $w->configure("-relief" => "sunken")
  }
}

# tkButtonUp --
# The procedure below is invoked when the mouse button is released
# in a button widget.  It restores the button's relief and invokes
# the command as long as the mouse hasn't left the button.
#
# Arguments:
# w -		The name of the widget.
sub butUp
{
 my $w = shift;
 if (defined($buttonWindow) && $buttonWindow == $w)
  {
   undef $buttonWindow;
   $w->configure("-relief" => $relief);
   if ($w->IS($Tk::window) && $w->cget("-state") ne "disabled")
    {
     $w->invoke;
    }
  }
}

# tkButtonInvoke --
# The procedure below is called when a button is invoked through
# the keyboard.  It simulate a press of the button via the mouse.
#
# Arguments:
# w -		The name of the widget.
sub Invoke 
{
 my $w = shift;
 if ($w->cget("-state") ne "disabled")
  {
   my $oldRelief = $w->cget("-relief");
   my $oldState  = $w->cget("-state");
   $w->configure("-state" => "active", "-relief" => "sunken");
   $w->idletasks;
   $w->after(100);
   $w->configure("-state" => $oldState, "-relief" => $oldRelief);
   $w->invoke;
  }
}



1;

__END__





