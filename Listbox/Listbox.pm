# Converted from listbox.tcl --
#
# This file defines the default bindings for Tk listbox widgets.
#
# @(#) listbox.tcl 1.7 94/12/17 16:05:18
#
# Copyright (c) 1994 The Regents of the University of California.
# Copyright (c) 1994 Sun Microsystems, Inc.
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.

package Tk::Listbox; 
require Tk;
require DynaLoader;
use AutoLoader;

@ISA = qw(DynaLoader Tk::Widget);

Tk::Widget->Construct('Listbox');

bootstrap Tk::Listbox; 

sub Tk_cmd { \&Tk::listbox }


1;
__END__

#
# Bind --
# This procedure is invoked the first time the mouse enters a listbox
# widget or a listbox widget receives the input focus. It creates
# all of the class bindings for listboxes.
#
# Arguments:
# event - Indicates which event caused the procedure to be invoked
# (Enter or FocusIn). It is used so that we can carry out
# the functions of that event in addition to setting up
# bindings.

sub xyIndex
{
 my $w = shift;
 my $Ev = $w->XEvent;
 return $w->index($Ev->xy);
}

sub classinit
{
 my ($class,$mw) = @_;

 # Standard Motif bindings:
 $mw->bind($class,"<1>",
	       sub
	       {
		my $w = shift;
		my $Ev = $w->XEvent;
		BeginSelect($w,$w->xyIndex($Ev));
	       }
	      )
 ;
 $mw->bind($class,"<B1-Motion>",
	       sub
	       {
		my $w = shift;
		my $Ev = $w->XEvent;
		Motion($w,$w->xyIndex($Ev));
	       }
	      )
 ;
 $mw->bind($class,"<ButtonRelease-1>",
	       sub
	       {
		my $w = shift;
		my $Ev = $w->XEvent;
		$w->CancelRepeat();
		$w->activate($Ev->xy);
	       }
	      )
 ;
 $mw->bind($class,"<Shift-1>",
	       sub
	       {
		my $w = shift;
		my $Ev = $w->XEvent;
		BeginExtend($w,$w->xyIndex($Ev));
	       }
	      )
 ;
 $mw->bind($class,"<Control-1>",
	       sub
	       {
		my $w = shift;
		my $Ev = $w->XEvent;
		BeginToggle($w,$w->xyIndex($Ev));
	       }
	      )
 ;
 $mw->bind($class,"<B1-Leave>",
	       sub
	       {
		my $w = shift;
		my $Ev = $w->XEvent;
		AutoScan($w,$Ev->x,$Ev->y)
	       }
	      )
 ;
 $mw->bind($class,"<B1-Enter>",
	       sub
	       {
		my $w = shift;
		my $Ev = $w->XEvent;
		$w->CancelRepeat()
	       }
	      )
 ;
 $mw->bind($class,"<Up>",
	       sub
	       {
		my $w = shift;
		my $Ev = $w->XEvent;
		UpDown($w,-1)
	       }
	      )
 ;
 $mw->bind($class,"<Shift-Up>",
	       sub
	       {
		my $w = shift;
		my $Ev = $w->XEvent;
		ExtendUpDown($w,-1)
	       }
	      )
 ;
 $mw->bind($class,"<Down>",
	       sub
	       {
		my $w = shift;
		my $Ev = $w->XEvent;
		UpDown($w,1)
	       }
	      )
 ;
 $mw->bind($class,"<Shift-Down>",
	       sub
	       {
		my $w = shift;
		my $Ev = $w->XEvent;
		ExtendUpDown($w,1)
	       }
	      )
 ;
 $mw->bind($class,"<Left>",
	       sub
	       {
		my $w = shift;
		my $Ev = $w->XEvent;
		$w->xview("scroll",-1,"units")
	       }
	      )
 ;
 $mw->bind($class,"<Control-Left>",
	       sub
	       {
		my $w = shift;
		my $Ev = $w->XEvent;
		$w->xview("scroll",-1,"pages")
	       }
	      )
 ;
 $mw->bind($class,"<Right>",
	       sub
	       {
		my $w = shift;
		my $Ev = $w->XEvent;
		$w->xview("scroll",1,"units")
	       }
	      )
 ;
 $mw->bind($class,"<Control-Right>",
	       sub
	       {
		my $w = shift;
		my $Ev = $w->XEvent;
		$w->xview("scroll",1,"pages")
	       }
	      )
 ;
 $mw->bind($class,"<Prior>",
	       sub
	       {
		my $w = shift;
		my $Ev = $w->XEvent;
		$w->yview("scroll",-1,"pages")
	       }
	      )
 ;
 $mw->bind($class,"<Next>",
	       sub
	       {
		my $w = shift;
		my $Ev = $w->XEvent;
		$w->yview("scroll",1,"pages")
	       }
	      )
 ;
 $mw->bind($class,"<Control-Prior>",
	       sub
	       {
		my $w = shift;
		my $Ev = $w->XEvent;
		$w->xview("scroll",-1,"pages")
	       }
	      )
 ;
 $mw->bind($class,"<Control-Next>",
	       sub
	       {
		my $w = shift;
		my $Ev = $w->XEvent;
		$w->xview("scroll",1,"pages")
	       }
	      )
 ;
 $mw->bind($class,"<Home>",
	       sub
	       {
		my $w = shift;
		my $Ev = $w->XEvent;
		$w->xview("moveto",0)
	       }
	      )
 ;
 $mw->bind($class,"<End>",
	       sub
	       {
		my $w = shift;
		my $Ev = $w->XEvent;
		$w->xview("moveto",1)
	       }
	      )
 ;
 $mw->bind($class,"<Control-Home>",
	       sub
	       {
		my $w = shift;
		my $Ev = $w->XEvent;
		$w->activate(0);
		$w->see(0);
		$w->selection("clear",0,"end");
		$w->selection("set",0)
	       }
	      )
 ;
 $mw->bind($class,"<Shift-Control-Home>",
	       sub
	       {
		my $w = shift;
		my $Ev = $w->XEvent;
		DataExtend($w,0)
	       }
	      )
 ;
 $mw->bind($class,"<Control-End>",
	       sub
	       {
		my $w = shift;
		my $Ev = $w->XEvent;
		$w->activate("end");
		$w->see("end");
		$w->selection("clear",0,"end");
		$w->selection("set","end")
	       }
	      )
 ;
 $mw->bind($class,"<Shift-Control-End>",
	       sub
	       {
		my $w = shift;
		my $Ev = $w->XEvent;
		DataExtend($w,"end")
	       }
	      )
 ;
 $mw->bind($class,"<F16>",
	       sub
	       {
		my $w = shift;
		my $Ev = $w->XEvent;
		if ($w->IS($w->SelectionOwner))
		 {
		  $w->Clipboard("clear");
		  $w->Clipboard("append",$w->SelectionGet);
		 }
	       }
	      )
 ;
 $mw->bind($class,"<space>",
	       sub
	       {
		my $w = shift;
		my $Ev = $w->XEvent;
		BeginSelect($w,$w->index("active"))
	       }
	      )
 ;
 $mw->bind($class,"<Select>",
	       sub
	       {
		my $w = shift;
		my $Ev = $w->XEvent;
		BeginSelect($w,$w->index("active"))
	       }
	      )
 ;
 $mw->bind($class,"<Control-Shift-space>",
	       sub
	       {
		my $w = shift;
		my $Ev = $w->XEvent;
		BeginExtend($w,$w->index("active"))
	       }
	      )
 ;
 $mw->bind($class,"<Shift-Select>",
	       sub
	       {
		my $w = shift;
		my $Ev = $w->XEvent;
		BeginExtend($w,$w->index("active"))
	       }
	      )
 ;
 $mw->bind($class,"<Escape>",
	       sub
	       {
		my $w = shift;
		my $Ev = $w->XEvent;
		Cancel($w)
	       }
	      )
 ;
 $mw->bind($class,"<Control-slash>",
	       sub
	       {
		my $w = shift;
		my $Ev = $w->XEvent;
		SelectAll($w)
	       }
	      )
 ;
 $mw->bind($class,"<Control-backslash>",
	       sub
	       {
		my $w = shift;
		my $Ev = $w->XEvent;
		if ($w->cget("-selectmode") ne "browse")
		 {
		  $w->selection("clear",0,"end")
		 }
	       }
	      )
 ;
 # Additional Tk bindings that aren't part of the Motif look and feel:
 $mw->bind($class,"<2>",
	       sub
	       {
		my $w = shift;
		my $Ev = $w->XEvent;
		$w->scan("mark",$Ev->x,$Ev->y)
	       }
	      )
 ;
 $mw->bind($class,"<B2-Motion>",
	       sub
	       {
		my $w = shift;
		my $Ev = $w->XEvent;
		$w->scan("dragto",$Ev->x,$Ev->y)
	       } ) ;
 return $class;
}
# BeginSelect --
#
# This procedure is typically invoked on button-1 presses. It begins
# the process of making a selection in the listbox. Its exact behavior
# depends on the selection mode currently in effect for the listbox;
# see the Motif documentation for details.
#
# Arguments:
# w - The listbox widget.
# el - The element for the selection operation (typically the
# one under the pointer). Must be in numerical form.
sub BeginSelect
{
 my $w = shift;
 my $el = shift;
 if ($w->cget("-selectmode") eq "multiple")
  {
   if ($w->selection("includes",$el))
    {
     $w->selection("clear",$el)
    }
   else
    {
     $w->selection("set",$el)
    }
  }
 else
  {
   $w->selection("clear",0,"end");
   $w->selection("set",$el);
   $w->selection("anchor",$el);
   @Selection = ();
   $Prev = $el
  }
}
# Motion --
#
# This procedure is called to process mouse motion events while
# button 1 is down. It may move or extend the selection, depending
# on the listbox's selection mode.
#
# Arguments:
# w - The listbox widget.
# el - The element under the pointer (must be a number).
sub Motion
{
 my $w = shift;
 my $el = shift;
 if ($el == $Prev)
  {
   return;
  }
 $anchor = $w->index("anchor");
 my $mode = $w->cget("-selectmode");
 if ($mode eq "browse")
  {
   $w->selection("clear",0,"end");
   $w->selection("set",$el);
   $Prev = $el;
  }
 elsif ($mode eq "extended")
  {
   $i = $Prev;
   if ($w->selection("includes","anchor"))
    {
     $w->selection("clear",$i,$el);
     $w->selection("set","anchor",$el)
    }
   else
    {
     $w->selection("clear",$i,$el);
     $w->selection("clear","anchor",$el)
    }
   while ($i < $el && $i < $anchor)
    {
     if (Tk::lsearch(\@Selection,$i) >= 0)
      {
       $w->selection("set",$i)
      }
     $i += 1
    }
   while ($i > $el && $i > $anchor)
    {
     if (Tk::lsearch(\@Selection,$i) >= 0)
      {
       $w->selection("set",$i)
      }
     $i += -1
    }
   $Prev = $el
  }
}
# BeginExtend --
#
# This procedure is typically invoked on shift-button-1 presses. It
# begins the process of extending a selection in the listbox. Its
# exact behavior depends on the selection mode currently in effect
# for the listbox; see the Motif documentation for details.
#
# Arguments:
# w - The listbox widget.
# el - The element for the selection operation (typically the
# one under the pointer). Must be in numerical form.
sub BeginExtend
{
 my $w = shift;
 my $el = shift;
 if ($w->cget("-selectmode") eq "extended" && $w->selection("includes","anchor"))
  {
   Motion($w,$el)
  }
}
# BeginToggle --
#
# This procedure is typically invoked on control-button-1 presses. It
# begins the process of toggling a selection in the listbox. Its
# exact behavior depends on the selection mode currently in effect
# for the listbox; see the Motif documentation for details.
#
# Arguments:
# w - The listbox widget.
# el - The element for the selection operation (typically the
# one under the pointer). Must be in numerical form.
sub BeginToggle
{
 my $w = shift;
 my $el = shift;
 if ($w->cget("-selectmode") eq "extended")
  {
   @Selection = $w->curselection();
   $Prev = $el;
   $w->selection("anchor",$el);
   if ($w->selection("includes",$el))
    {
     $w->selection("clear",$el)
    }
   else
    {
     $w->selection("set",$el)
    }
  }
}
# AutoScan --
# This procedure is invoked when the mouse leaves an entry window
# with button 1 down. It scrolls the window up, down, left, or
# right, depending on where the mouse left the window, and reschedules
# itself as an "after" command so that the window continues to scroll until
# the mouse moves back into the window or the mouse button is released.
#
# Arguments:
# w - The entry window.
# x - The x-coordinate of the mouse when it left the window.
# y - The y-coordinate of the mouse when it left the window.
sub AutoScan
{
 my $w = shift;
 my $x = shift;
 my $y = shift;
 if ($y >= $w->height)
  {
   $w->yview("scroll",1,"units")
  }
 elsif ($y < 0)
  {
   $w->yview("scroll",-1,"units")
  }
 elsif ($x >= $w->width)
  {
   $w->xview("scroll",2,"units")
  }
 elsif ($x < 0)
  {
   $w->xview("scroll",-2,"units")
  }
 else
  {
   return;
  }
 Motion($w,$w->index("@" . $x . ',' . $y));
 $w->afterId($w->after(50,"AutoScan",$w,$x,$y));
}
# UpDown --
#
# Moves the location cursor (active element) up or down by one element,
# and changes the selection if we're in browse or extended selection
# mode.
#
# Arguments:
# w - The listbox widget.
# amount - +1 to move down one item, -1 to move back one item.
sub UpDown
{
 my $w = shift;
 my $amount = shift;
 $w->activate($w->index("active")+$amount);
 $w->see("active");
 $LNet__0 = $w->cget("-selectmode");
 if ($LNet__0 eq "browse")
  {
   $w->selection("clear",0,"end");
   $w->selection("set","active")
  }
 elsif ($LNet__0 eq "extended")
  {
   $w->selection("clear",0,"end");
   $w->selection("set","active");
   $w->selection("anchor","active");
   $Prev = $w->index("active");
   @Selection = ();
  }
}
# ExtendUpDown --
#
# Does nothing unless we're in extended selection mode; in this
# case it moves the location cursor (active element) up or down by
# one element, and extends the selection to that point.
#
# Arguments:
# w - The listbox widget.
# amount - +1 to move down one item, -1 to move back one item.
sub ExtendUpDown
{
 my $w = shift;
 my $amount = shift;
 if ($w->cget("-selectmode") ne "extended")
  {
   return;
  }
 $w->activate($w->index("active")+$amount);
 $w->see("active");
 Motion($w,$w->index("active"))
}
# DataExtend
#
# This procedure is called for key-presses such as Shift-KEndData.
# If the selection mode isn't multiple or extend then it does nothing.
# Otherwise it moves the active element to el and, if we're in
# extended mode, extends the selection to that point.
#
# Arguments:
# w - The listbox widget.
# el - An integer element number.
sub DataExtend
{
 my $w = shift;
 my $el = shift;
 $mode = $w->cget("-selectmode");
 if ($mode eq "extended")
  {
   $w->activate($el);
   $w->see($el);
   if ($w->selection("includes","anchor"))
    {
     Motion($w,$el)
    }
  }
 elsif ($mode eq "multiple")
  {
   $w->activate($el);
   $w->see($el)
  }
}
# Cancel
#
# This procedure is invoked to cancel an extended selection in
# progress. If there is an extended selection in progress, it
# restores all of the items between the active one and the anchor
# to their previous selection state.
#
# Arguments:
# w - The listbox widget.
sub Cancel
{
 my $w = shift;
 if ($w->cget("-selectmode") ne "extended")
  {
   return;
  }
 $first = $w->index("anchor");
 $last = $Prev;
 if ($first > $last)
  {
   $tmp = $first;
   $first = $last;
   $last = $tmp
  }
 $w->selection("clear",$first,$last);
 while ($first <= $last)
  {
   if (Tk::lsearch(\@Selection,$first) >= 0)
    {
     $w->selection("set",$first)
    }
   $first += 1
  }
}
# SelectAll
#
# This procedure is invoked to handle the "select all" operation.
# For single and browse mode, it just selects the active element.
# Otherwise it selects everything in the widget.
#
# Arguments:
# w - The listbox widget.
sub SelectAll
{
 my $w = shift;
 my $mode = $w->cget("-selectmode");
 if ($mode eq "single" || $mode eq "browse")
  {
   $w->selection("clear",0,"end");
   $w->selection("set","active")
  }
 else
  {
   $w->selection("set",0,"end")
  }
}

sub setlist
{
 my $w = shift;
 $w->delete(0,"end");
 $w->insert("end",@_);
}

sub Getselected
{
 my ($w) = @_;
 my $i;
 my (@result) = ();
 foreach $i ($w->curselection)
  {
   push(@result,$w->get($i));
  }
 return (wantarray) ? @result : $result[0];
}
