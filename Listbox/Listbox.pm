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

use vars qw($VERSION @ISA);
$VERSION = '3.013'; # $Id: //depot/Tk8/Listbox/Listbox.pm#13$

use Tk qw(Ev);
require Tk::Clipboard;
use AutoLoader;

use base  qw(Tk::Clipboard Tk::Widget);

Construct Tk::Widget 'Listbox';

bootstrap Tk::Listbox $Tk::VERSION; 

sub Tk_cmd { \&Tk::listbox } 

Tk::Methods("activate","bbox","curselection","delete","get","index",
            "insert","nearest","scan","see","selection","size",
            "xview","yview");

use Tk::Submethods ( 'selection' => [qw(anchor clear includes set)],
                     'scan' => [qw(mark dragto)]
                   );
 
*Getselected = \&getSelected;

sub clipEvents
{
 return qw[Copy];
}

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

sub ClassInit
{
 my ($class,$mw) = @_;
 $class->SUPER::ClassInit($mw);
 # Standard Motif bindings:
 $mw->bind($class,"<1>",['BeginSelect',Ev('index',Ev('@'))]);
 $mw->bind($class,"<B1-Motion>",['Motion',Ev('index',Ev('@'))]);
 $mw->bind($class,"<ButtonRelease-1>",
	       sub
	       {
		my $w = shift;
		my $Ev = $w->XEvent;
		$w->CancelRepeat;
		$w->activate($Ev->xy);
	       }
	      )
 ;
 $mw->bind($class,"<Shift-1>",['BeginExtend',Ev('index',Ev('@'))]);
 $mw->bind($class,"<Control-1>",['BeginToggle',Ev('index',Ev('@'))]);

 $mw->bind($class,"<B1-Leave>",['AutoScan',Ev('x'),Ev('y')]);
 $mw->bind($class,"<B1-Enter>",'CancelRepeat');
 $mw->bind($class,"<Up>",['UpDown',-1]);
 $mw->bind($class,"<Shift-Up>",['ExtendUpDown',-1]);
 $mw->bind($class,"<Down>",['UpDown',1]);
 $mw->bind($class,"<Shift-Down>",['ExtendUpDown',1]);

 $mw->XscrollBind($class); 
 $mw->PriorNextBind($class); 

 $mw->bind($class,"<Control-Home>",
	       sub
	       {
		my $w = shift;
		my $Ev = $w->XEvent;
		$w->activate(0);
		$w->see(0);
		$w->selectionClear(0,"end");
		$w->selectionSet(0)
	       }
	      )
 ;
 $mw->bind($class,"<Shift-Control-Home>",['DataExtend',0]);
 $mw->bind($class,"<Control-End>",
	       sub
	       {
		my $w = shift;
		my $Ev = $w->XEvent;
		$w->activate("end");
		$w->see("end");
		$w->selectionClear(0,"end");
		$w->selectionSet('end')
	       }
	      )
 ;
 $mw->bind($class,"<Shift-Control-End>",['DataExtend','end']);
 $class->clipboardOperations($mw,'Copy');
 $mw->bind($class,"<space>",['BeginSelect',Ev('index','active')]);
 $mw->bind($class,"<Select>",['BeginSelect',Ev('index','active')]);
 $mw->bind($class,"<Control-Shift-space>",['BeginExtend',Ev('index','active')]);
 $mw->bind($class,"<Shift-Select>",['BeginExtend',Ev('index','active')]);
 $mw->bind($class,"<Escape>",'Cancel');
 $mw->bind($class,"<Control-slash>",'SelectAll');
 $mw->bind($class,"<Control-backslash>",
	       sub
	       {
		my $w = shift;
		my $Ev = $w->XEvent;
		if ($w->cget("-selectmode") ne "browse")
		 {
		  $w->selectionClear(0,"end");
		 }
	       }
	      )
 ;
 # Additional Tk bindings that aren't part of the Motif look and feel:
 $mw->bind($class,"<2>",['scan','mark',Ev('x'),Ev('y')]);
 $mw->bind($class,"<B2-Motion>",['scan','dragto',Ev('x'),Ev('y')]);
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
   if ($w->selectionIncludes($el))
    {
     $w->selectionClear($el)
    }
   else
    {
     $w->selectionSet($el)
    }
  }
 else
  {
   $w->selectionClear(0,"end");
   $w->selectionSet($el);
   $w->selectionAnchor($el);
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
 if (defined($Prev) && $el == $Prev)
  {
   return;
  }
 $anchor = $w->index("anchor");
 my $mode = $w->cget("-selectmode");
 if ($mode eq "browse")
  {
   $w->selectionClear(0,"end");
   $w->selectionSet($el);
   $Prev = $el;
  }
 elsif ($mode eq "extended")
  {
   $i = $Prev;
   if ($w->selectionIncludes('anchor'))
    {
     $w->selectionClear($i,$el);
     $w->selectionSet("anchor",$el)
    }
   else
    {
     $w->selectionClear($i,$el);
     $w->selectionClear("anchor",$el)
    }
   while ($i < $el && $i < $anchor)
    {
     if (Tk::lsearch(\@Selection,$i) >= 0)
      {
       $w->selectionSet($i)
      }
     $i += 1
    }
   while ($i > $el && $i > $anchor)
    {
     if (Tk::lsearch(\@Selection,$i) >= 0)
      {
       $w->selectionSet($i)
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
 if ($w->cget("-selectmode") eq "extended" && $w->selectionIncludes("anchor"))
  {
   $w->Motion($el)
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
   $w->selectionAnchor($el);
   if ($w->selectionIncludes($el))
    {
     $w->selectionClear($el)
    }
   else
    {
     $w->selectionSet($el)
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
 $w->Motion($w->index("@" . $x . ',' . $y));
 $w->RepeatId($w->after(50,"AutoScan",$w,$x,$y));
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
   $w->selectionClear(0,"end");
   $w->selectionSet("active")
  }
 elsif ($LNet__0 eq "extended")
  {
   $w->selectionClear(0,"end");
   $w->selectionSet("active");
   $w->selectionAnchor("active");
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
 $w->Motion($w->index("active"))
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
   if ($w->selectionIncludes("anchor"))
    {
     $w->Motion($el)
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
 $w->selectionClear($first,$last);
 while ($first <= $last)
  {
   if (Tk::lsearch(\@Selection,$first) >= 0)
    {
     $w->selectionSet($first)
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
   $w->selectionClear(0,"end");
   $w->selectionSet("active")
  }
 else
  {
   $w->selectionSet(0,"end")
  }
}

sub SetList
{
 my $w = shift;
 $w->delete(0,"end");
 $w->insert("end",@_);
}

sub deleteSelected
{
 my $w = shift;
 my $i;
 foreach $i (reverse $w->curselection)
  {
   $w->delete($i);
  }
}

sub clipboardPaste
{
 my $w = shift;
 my $index = $w->index('active') || $w->index($w->XEvent->xy);
 my $str;
 eval {local $SIG{__DIE__}; $str = $w->clipboardGet };
 return if $@;
 foreach (split("\n",$str))
  {
   $w->insert($index++,$_);
  }
}      

sub getSelected
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



1;
__END__
