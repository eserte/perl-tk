# Converted from entry.tcl --
#
# This file defines the default bindings for Tk entry widgets.
#
# @(#) entry.tcl 1.22 94/12/17 16:05:14
#
# Copyright (c) 1992-1994 The Regents of the University of California.
# Copyright (c) 1994 Sun Microsystems, Inc.
# Copyright (c) 1995-1996 Nick Ing-Simmons. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself, subject 
# to additional disclaimer in license.terms due to partial
# derivation from Tk4.0 sources.

package Tk::Entry; 
require Tk::Widget;
require Tk::Clipboard;
require DynaLoader;
use AutoLoader;

@ISA = qw(DynaLoader Tk::Widget); 

import Tk qw(Ev);

Tk::Widget->Construct('Entry');

bootstrap Tk::Entry $Tk::VERSION;

sub Tk_cmd { \&Tk::entry }


1;

__END__

sub wordstart
{my ($w,$pos) = @_;
 my $string = $w->get;
 $pos = $w->index("insert")-1 unless(defined $pos);
 $string = substr($string,0,$pos);
 $string =~ s/\S*$//;
 length $string;
}

sub wordend
{my ($w,$pos) = @_;
 my $string = $w->get;
 my $anc = length $string;
 $pos = $w->index("insert") unless(defined $pos);
 $string = substr($string,$pos);
 $string =~ s/^(?:((?=\s)\s*|(?=\S)\S*))//x;
 $anc - length($string);
}


#
# Bind --
# This procedure is invoked the first time the mouse enters an
# entry widget or an entry widget receives the input focus. It creates
# all of the class bindings for entries.
#
# Arguments:
# event - Indicates which event caused the procedure to be invoked
# (Enter or FocusIn). It is used so that we can carry out
# the functions of that event in addition to setting up
# bindings.
sub ClassInit
{
 my ($class,$mw) = @_;
 # Standard Motif bindings:
 $mw->bind($class,"<1>",
             sub
             {
              my $w = shift;
              my $Ev = $w->XEvent;
              Button1($w,$Ev->x);
              $w->SelectionClear;
             });

 $mw->bind($class,"<B1-Motion>",['MouseSelect',Ev("x")]);

 $mw->bind($class,"<Double-1>",
             sub
             {
              my $w = shift;
              my $Ev = $w->XEvent;
              $Tk::selectMode = "word";
              MouseSelect($w,$Ev->x);
              eval { $w->icursor("sel.first") }
             } ) ;
 $mw->bind($class,"<Triple-1>",
             sub
             {
              my $w = shift;
              my $Ev = $w->XEvent;
              $Tk::selectMode = "line";
              MouseSelect($w,$Ev->x);
              $w->icursor(0)
             } ) ;
 $mw->bind($class,"<Shift-1>",
             sub
             {
              my $w = shift;
              my $Ev = $w->XEvent;
              $Tk::selectMode = "char";
              $w->selection("adjust","@" . $Ev->x)
             } ) ;
 $mw->bind($class,"<Double-Shift-1>",
             sub
             {
              my $w = shift;
              my $Ev = $w->XEvent;
              $Tk::selectMode = "word";
              MouseSelect($w,$Ev->x)
             } ) ;
 $mw->bind($class,"<Triple-Shift-1>",
             sub
             {
              my $w = shift;
              my $Ev = $w->XEvent;
              $Tk::selectMode = "line";
              MouseSelect($w,$Ev->x)
             } ) ;
 $mw->bind($class,"<B1-Leave>",['AutoScan',Ev("x")]);
 $mw->bind($class,"<B1-Enter>",'CancelRepeat');
 $mw->bind($class,"<ButtonRelease-1>",'CancelRepeat');
 $mw->bind($class,"<Control-1>",
             sub
             {
              my $w = shift;
              my $Ev = $w->XEvent;
              $w->icursor("@" . $Ev->x)
             } ) ;
 $mw->bind($class,"<Left>",
             sub
             {
              my $w = shift;
              $w->SetCursor($w->index("insert")-1)
             } ) ;
 $mw->bind($class,"<Right>",
             sub
             {
              my $w = shift;
              $w->SetCursor($w->index("insert")+1)
             } ) ;
 $mw->bind($class,"<Shift-Left>",
             sub
             {
              my $w = shift;
              $w->KeySelect($w->index("insert")-1);
             } ) ;
 $mw->bind($class,"<Shift-Right>",
             sub
             {
              my $w = shift;
              $w->KeySelect($w->index("insert")+1);
             } ) ;
 $mw->bind($class,"<Control-Left>",
             sub
             {
              my $w = shift;
              $w->SetCursor($w->wordstart)
             } ) ;
 $mw->bind($class,"<Control-Right>",
             sub
             {
              my $w = shift;
              $w->SetCursor($w->wordend)
             } ) ;
 $mw->bind($class,"<Shift-Control-Left>",
             sub
             {
              my $w = shift;
              my $Ev = $w->XEvent;
              $w->KeySelect($w->wordstart) ;
             } ) ;
 $mw->bind($class,"<Shift-Control-Right>",
             sub
             {
              my $w = shift;
              $w->KeySelect($w->wordend) ;
             } ) ;
 $mw->bind($class,"<Home>",['SetCursor',0]);
 $mw->bind($class,"<Shift-Home>",
             sub
             {
              my $w = shift;
              $w->KeySelect(0);
             } ) ;
 $mw->bind($class,"<End>",['SetCursor',"end"]);
 $mw->bind($class,"<Shift-End>",
             sub
             {
              my $w = shift;
              $w->KeySelect("end");
             } ) ;
 $mw->bind($class,"<Delete>",
             sub
             {
              my $w = shift;
              if ($w->selection("present"))
               {
                $w->deleteSelected
               }
              else
               {
                $w->delete("insert")
               }
             } ) ;

 $mw->bind($class,"<BackSpace>","Backspace");

 $mw->bind($class,"<Control-space>",
             sub
             {
              my $w = shift;
              $w->selection("from","insert")
             } ) ;
 $mw->bind($class,"<Select>",
             sub
             {
              my $w = shift;
              $w->selection("from","insert")
             } ) ;
 $mw->bind($class,"<Control-Shift-space>",
             sub
             {
              my $w = shift;
              $w->selection("adjust","insert")
             } ) ;
 $mw->bind($class,"<Shift-Select>",
             sub
             {
              my $w = shift;
              $w->selection("adjust","insert")
             } ) ;
 $mw->bind($class,"<Control-slash>",
             sub
             {
              my $w = shift;
              $w->selection("range",0,"end")
             } ) ;
 $mw->bind($class,"<Control-backslash>",'SelectionClear');

 $class->clipboardKeysyms($mw,"F16","F20","F18");

 $mw->bind($class,"<KeyPress>", ['Insert',Ev(A)]);

 # Ignore all Alt, Meta, and Control keypresses unless explicitly bound.
 # Otherwise, if a widget binding for one of these is defined, the
 # <KeyPress> class binding will also fire and insert the character,
 # which is wrong.  Ditto for Escape, Return, and Tab.

 $mw->bind($class,'<Alt-KeyPress>' ,'NoOp');
 $mw->bind($class,'<Meta-KeyPress>' ,'NoOp');
 $mw->bind($class,'<Control-KeyPress>' ,'NoOp');
 $mw->bind($class,'<Escape>' ,'NoOp');
 $mw->bind($class,'<Return>' ,'NoOp');
 $mw->bind($class,'<Tab>' ,'NoOp');

 $mw->bind($class,"<Insert>",
             sub
             {
              my $w = shift;
              eval { Insert($w,$w->SelectionGet)}
             } ) ;
 # Additional emacs-like bindings:
 if (!$Tk::strictMotif)
  {
   $mw->bind($class,"<Control-a>",['SetCursor',0]);
   $mw->bind($class,"<Control-b>",
               sub
               {
                my $w = shift;
                $w->SetCursor($w->index("insert")-1)
               } ) ;
   $mw->bind($class,"<Control-d>",['delete','insert']);
   $mw->bind($class,"<Control-e>",['SetCursor',"end"]);
   $mw->bind($class,"<Control-f>",
               sub
               {
                my $w = shift;
                $w->SetCursor($w->index("insert")+1)
               } ) ;
   $mw->bind($class,"<Control-h>","Backspace");
   $mw->bind($class,"<Control-k>",["delete","insert","end"]);

   $mw->bind($class,"<Control-t>",'Transpose');

   $mw->bind($class,"<Meta-b>",['SetCursor',Ev('wordstart')]);
   $mw->bind($class,"<Meta-d>",
               sub
               {
                my $w = shift;
                $w->delete("insert",$w->wordend)
               } ) ;
   $mw->bind($class,"<Meta-f>",
               sub
               {
                my $w = shift;
                $w->SetCursor($w->wordend)
               } ) ;
   $mw->bind($class,"<Meta-BackSpace>",
               sub
               {
                my $w = shift;
                $w->delete($w->wordstart ,"insert")
               } ) ;
   $class->clipboardKeysyms($mw,"Meta-w","Control-w","Control-y");
   # A few additional bindings of my own.
   $mw->bind($class,"<Control-v>",
               sub
               {
                my $w = shift;
                my $Ev = $w->XEvent;
                eval
                 {
                  $w->insert("insert",$w->SelectionGet);
                  $w->SeeInsert;
                 }
               } ) ;
   $mw->bind($class,"<Control-w>",
               sub
               {
                my $w = shift;
                my $Ev = $w->XEvent;
                $w->delete($w->wordstart ,"insert")
               } ) ;
   $mw->bind($class,"<2>",
               sub
               {
                my $w = shift;
                my $Ev = $w->XEvent;
                $w->scan("mark",$Ev->x);
                $Tk::x = $Ev->x;
                $Tk::y = $Ev->y;
                $Tk::mouseMoved = 0
               } ) ;
   $mw->bind($class,"<B2-Motion>",
               sub
               {
                my $w = shift;
                my $Ev = $w->XEvent;
                if (abs(($Ev->x-$Tk::x)) > 2)
                 {
                  $Tk::mouseMoved = 1
                 }
                $w->scan("dragto",$Ev->x)
               } ) ;
   $mw->bind($class,"<ButtonRelease-2>",
               sub
               {
                my $w = shift;
                my $Ev = $w->XEvent;
                if (!$Tk::mouseMoved)
                 {
                  eval
                   {
                    $w->insert("insert",$w->SelectionGet);
                    $w->SeeInsert;
                   }
                 }
               } )
  }
 return $class;
}
# Button1 --
# This procedure is invoked to handle button-1 presses in entry
# widgets. It moves the insertion cursor, sets the selection anchor,
# and claims the input focus.
#
# Arguments:
# w - The entry window in which the button was pressed.
# x - The x-coordinate of the button press.
sub Button1
{
 my $w = shift;
 my $x = shift;
 $Tk::selectMode = "char";
 $Tk::mouseMoved = 0;
 $Tk::pressX = $x;
 $w->icursor("@" . $x);
 $w->selection("from","@" . $x);
 if ($w->cget("-state") eq "normal")
  {
   $w->focus()
  }
}
# MouseSelect --
# This procedure is invoked when dragging out a selection with
# the mouse. Depending on the selection mode (character, word,
# line) it selects in different-sized units. This procedure
# ignores mouse motions initially until the mouse has moved from
# one character to another or until there have been multiple clicks.
#
# Arguments:
# w - The entry window in which the button was pressed.
# x - The x-coordinate of the mouse.
sub MouseSelect
{
 my $w = shift;
 my $x = shift;
 my $cur = $w->index("@" . $x);
 my $anchor = $w->index("anchor");
 if (($cur != $anchor) || (abs($Tk::pressX - $x) >= 3))
  {
   $Tk::mouseMoved = 1
  }
 my $mode = $Tk::selectMode;
 if ($mode eq "char")
  {
   if ($Tk::mouseMoved)
    {
     if ($cur < $anchor)
      {
       $w->selection("to",$cur)
      }
     else
      {
       $w->selection("to",$cur+1)
      }
    }
  }
 elsif ($mode eq "word")
  {
   if ($cur < $w->index("anchor"))
    {
     $w->selection("range",$w->wordstart($cur),$w->wordend($anchor-1))
    }
   else
    {
     $w->selection("range",$w->wordstart($anchor),$w->wordend($cur))
    }
  }
 elsif ($mode eq "line")
  {
   $w->selection("range",0,"end")
  }
 $w->idletasks;
}
# AutoScan --
# This procedure is invoked when the mouse leaves an entry window
# with button 1 down.  It scrolls the window left or right,
# depending on where the mouse is, and reschedules itself as an
# "after" command so that the window continues to scroll until the
# mouse moves back into the window or the mouse button is released.
#
# Arguments:
# w - The entry window.
# x - The x-coordinate of the mouse when it left the window.
sub AutoScan
{
 my $w = shift;
 my $x = shift;
 if ($x >= $w->width)
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
 MouseSelect($w,$x);
 $w->RepeatId($w->after(50,"AutoScan",$w,$x))
}
# KeySelect
# This procedure is invoked when stroking out selections using the
# keyboard. It moves the cursor to a new position, then extends
# the selection to that position.
#
# Arguments:
# w - The entry window.
# new - A new position for the insertion cursor (the cursor hasn't
# actually been moved to this position yet).
sub KeySelect
{
 my $w = shift;
 my $new = shift;
 if (!$w->selection("present"))
  {
   $w->selection("from","insert");
   $w->selection("to",$new)
  }
 else
  {
   $w->selection("adjust",$new)
  }
 $w->icursor($new);
 $w->SeeInsert;
}
# Insert --
# Insert a string into an entry at the point of the insertion cursor.
# If there is a selection in the entry, and it covers the point of the
# insertion cursor, then delete the selection before inserting.
#
# Arguments:
# w - The entry window in which to insert the string
# s - The string to insert (usually just a single character)
sub Insert
{
 my $w = shift;
 my $s = shift;
 return unless (defined $s && $s ne "");
 eval
  {
   $insert = $w->index("insert");
   if ($w->index("sel.first") <= $insert && $w->index("sel.last") >= $insert)
    {
     $w->deleteSelected
    }
  };
 $w->insert("insert",$s);
 $w->SeeInsert
}
# Backspace --
# Backspace over the character just before the insertion cursor.
#
# Arguments:
# w - The entry window in which to backspace.
sub Backspace
{
 my $w = shift;
 if ($w->selection("present"))
  {
   $w->deleteSelected
  }
 else
  {
   my $x = $w->index("insert")-1;
   $w->delete($x) if ($x >= 0);
  }
}
# SeeInsert
# Make sure that the insertion cursor is visible in the entry window.
# If not, adjust the view so that it is.
#
# Arguments:
# w - The entry window.
sub SeeInsert
{
 my $w = shift;
 my $c = $w->index("insert");
#
# Probably a bug in your version of tcl/tk (I've not this problem
# when I test Entry in the widget demo for tcl/tk)
# index("\@0") give always 0. Consequence :
#    if you make <Control-E> or <Control-F> view is adapted
#    but with <Control-A> or <Control-B> view is not adapted
#
 my $left = $w->index("\@0");
 if ($left > $c)
  {
   $w->xview($c);
   return;
  }
 my $x = $w->width;
 while ($w->index("@" . $x) <= $c && $left < $c)
  {
   $left += 1;
   $w->xview($left)
  }
}
# SetCursor
# Move the insertion cursor to a given position in an entry. Also
# clears the selection, if there is one in the entry, and makes sure
# that the insertion cursor is visible.
#
# Arguments:
# w - The entry window.
# pos - The desired new position for the cursor in the window.
sub SetCursor
{
 my $w = shift;
 my $pos = shift;
 $w->icursor($pos);
 $w->SelectionClear;
 $w->SeeInsert;
}
# Transpose
# This procedure implements the "transpose" function for entry widgets.
# It tranposes the characters on either side of the insertion cursor,
# unless the cursor is at the end of the line.  In this case it
# transposes the two characters to the left of the cursor.  In either
# case, the cursor ends up to the right of the transposed characters.
#
# Arguments:
# w - The entry window.
sub Transpose
{
 my $w = shift;
 my $i = $w->index('insert');
 $i++ if ($i < $w->index('end'));
 my $first = $i-2;
 return if ($first < 0);
 my $str = $w->get;
 my $new = substr($str,$i-1,1) . substr($str,$first,1);
 $w->delete($first,$i);
 $w->insert('insert',$new);
 $w->SeeInsert;
}

sub deleteSelected
{
 shift->delete("sel.first","sel.last")
}
