# Converted from scale.tcl --
#
# This file defines the default bindings for Tk scale widgets.
#
# @(#) scale.tcl 1.3 94/12/17 16:05:23
#
# Copyright (c) 1994 The Regents of the University of California.
# Copyright (c) 1994 Sun Microsystems, Inc.
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.

package Tk::Scale; 
require Tk;
require DynaLoader;
use AutoLoader;
@ISA = qw(DynaLoader Tk::Widget);

Tk::Widget->Construct('Scale');

bootstrap Tk::Scale;

sub Tk_cmd { \&Tk::scale }


import Tk qw(Ev);


1;

__END__

#
# Bind --
# This procedure below invoked the first time the mouse enters a
# scale widget or a scale widget receives the input focus. It creates
# all of the class bindings for scales.
#
# Arguments:
# event - Indicates which event caused the procedure to be invoked
# (Enter or FocusIn). It is used so that we can carry out
# the functions of that event in addition to setting up
# bindings.
sub classinit
{
 my ($class,$mw) = @_;
 $mw->bind($class,"<Enter>",
	     sub
	     {
	      my $w = shift;
	      my $Ev = $w->XEvent;
	      if ($Tk::tk_strictMotif)
	       {
		$Tk::activeBg = $w->cget("-activebackground");
		$w->configure("-activebackground",$w->cget("-background"))
	       }
	      Activate($w,$Ev->x,$Ev->y)
	     }
	    )
 ;
 $mw->bind($class,"<Motion>",['Activate',Ev('x'),Ev('y')]);
 $mw->bind($class,"<Leave>",
	     sub
	     {
	      my $w = shift;
	      my $Ev = $w->XEvent;
	      if ($Tk::tk_strictMotif)
	       {
		$w->configure("-activebackground",$Tk::activeBg)
	       }
	      if ($w->cget("-state") eq "active")
	       {
		$w->configure("-state","normal")
	       }
	     }
	    )
 ;
 $mw->bind($class,"<1>",['ButtonDown',Ev('x'),Ev('y')]);
 $mw->bind($class,"<B1-Motion>",['Drag',Ev('x'),Ev('y')]);
 $mw->bind($class,"<B1-Leave>",'NoOp');
 $mw->bind($class,"<B1-Enter>",'NoOp');
 $mw->bind($class,"<ButtonRelease-1>",
	     sub
	     {
	      my $w = shift;
	      my $Ev = $w->XEvent;
	      $w->CancelRepeat();
	      EndDrag($w);
	      Activate($w,$Ev->x,$Ev->y)
	     }
	    )
 ;
 $mw->bind($class,"<2>",['ButtonDown',Ev('x'),Ev('y')]);
 $mw->bind($class,"<B2-Motion>",['Drag',Ev('x'),Ev('y')]);
 $mw->bind($class,"<B2-Leave>",'NoOp');
 $mw->bind($class,"<B2-Enter>",'NoOp');
 $mw->bind($class,"<ButtonRelease-2>",
	     sub
	     {
	      my $w = shift;
	      my $Ev = $w->XEvent;
	      $w->CancelRepeat();
	      EndDrag($w);
	      Activate($w,$Ev->x,$Ev->y)
	     }
	    )
 ;
 $mw->bind($class,"<Control-1>",['ControlPress',Ev('x'),Ev('y')]);
 $mw->bind($class,"<Up>",['Increment',"up","little","noRepeat"]);
 $mw->bind($class,"<Down>",['Increment',"down","little","noRepeat"]);
 $mw->bind($class,"<Left>",['Increment',"up","little","noRepeat"]);
 $mw->bind($class,"<Right>",['Increment',"down","little","noRepeat"]);
 $mw->bind($class,"<Control-Up>",['Increment',"up","big","noRepeat"]);
 $mw->bind($class,"<Control-Down>",['Increment',"down","big","noRepeat"]);
 $mw->bind($class,"<Control-Left>",['Increment',"up","big","noRepeat"]);
 $mw->bind($class,"<Control-Right>",['Increment',"down","big","noRepeat"]);
 $mw->bind($class,"<Home>",["set",Ev("cget","-from")]);
 $mw->bind($class,"<End>",["set",Ev("cget","-to")]);
 return $class;
}
# Activate --
# This procedure is invoked to check a given x-y position in the
# scale and activate the slider if the x-y position falls within
# the slider.
#
# Arguments:
# w - The scale widget.
# x, y - Mouse coordinates.
sub Activate
{
 my $w = shift;
 my $x = shift;
 my $y = shift;
 return if ($w->cget("-state") eq "disabled");
 my $ident = $w->identify($x,$y);
 if (defined($ident) && $ident eq "slider")
  {
   $w->configure("-state","active")
  }
 else
  {
   $w->configure("-state","normal")
  }
}
# ButtonDown --
# This procedure is invoked when a button is pressed in a scale. It
# takes different actions depending on where the button was pressed.
#
# Arguments:
# w - The scale widget.
# x, y - Mouse coordinates of button press.
sub ButtonDown
{
 my $w = shift;
 my $x = shift;
 my $y = shift;
 $Tk::dragging = 0;
 $el = $w->identify($x,$y);
 if ($el eq "trough1")
  {
   Increment($w,"up","little","initial")
  }
 elsif ($el eq "trough2")
  {
   Increment($w,"down","little","initial")
  }
 elsif ($el eq "slider")
  {
   $Tk::dragging = 1;
   my @coords = $w->coords();
   $Tk::deltaX = $x-$coords[0];
   $Tk::deltaY = $y-$coords[1];
  }
}
# Drag --
# This procedure is called when the mouse is dragged with
# mouse button 1 down. If the drag started inside the slider
# (i.e. the scale is active) then the scale's value is adjusted
# to reflect the mouse's position.
#
# Arguments:
# w - The scale widget.
# x, y - Mouse coordinates.
sub Drag
{
 my $w = shift;
 my $x = shift;
 my $y = shift;
 if (!$Tk::dragging)
  {
   return;
  }
 $w->set($w->get($x-$Tk::deltaX,$y-$Tk::deltaY))
}
# EndDrag --
# This procedure is called to end an interactive drag of the
# slider.  It just marks the drag as over.
# Arguments:
# w - The scale widget.
sub EndDrag
{
 my $w = shift;
 if (!$Tk::dragging)
  {
   return;
  }
 $Tk::dragging = 0;
}
# Increment --
# This procedure is invoked to increment the value of a scale and
# to set up auto-repeating of the action if that is desired. The
# way the value is incremented depends on the "dir" and "big"
# arguments.
#
# Arguments:
# w - The scale widget.
# dir - "up" means move value towards -from, "down" means
# move towards -to.
# big - Size of increments: "big" or "little".
# repeat - Whether and how to auto-repeat the action: "noRepeat"
# means don't auto-repeat, "initial" means this is the
# first action in an auto-repeat sequence, and "again"
# means this is the second repetition or later.
sub Increment
{
 my $w = shift;
 my $dir = shift;
 my $big = shift;
 my $repeat = shift;
 my $inc;
 if ($big eq "big")
  {
   $inc = $w->cget("-bigincrement");
   if ($inc == 0)
    {
     $inc = abs(($w->cget("-to")-$w->cget("-from")))/10.0
    }
   if ($inc < $w->cget("-resolution"))
    {
     $inc = $w->cget("-resolution")
    }
  }
 else
  {
   $inc = $w->cget("-resolution")
  }
 if ($w->cget("-from") > $w->cget("-to") ^ $dir eq "up")
  {
   $inc = -$inc
  }
 $w->set($w->get()+$inc);
 if ($repeat eq "again")
  {
   $w->afterId($w->after($w->cget("-repeatinterval"),"Increment",$w,$dir,$big,"again"));
  }
 elsif ($repeat eq "initial")
  {
   $w->afterId($w->after($w->cget("-repeatdelay"),"Increment",$w,$dir,$big,"again"));
  }
}
# ControlPress --
# This procedure handles button presses that are made with the Control
# key down. Depending on the mouse position, it adjusts the scale
# value to one end of the range or the other.
#
# Arguments:
# w - The scale widget.
# x, y - Mouse coordinates where the button was pressed.
sub ControlPress
{
 my $w = shift;
 my $x = shift;
 my $y = shift;
 my $el = $w->identify($x,$y);
 if ($el eq "trough1")
  {
   $w->set($w->cget("-from"))
  }
 elsif ($el eq "trough2")
  {
   $w->set($w->cget("-to"))
  }
}


