# text.tcl --
#
# This file defines the default bindings for Tk text widgets.
#
# @(#) text.tcl 1.18 94/12/17 16:05:26
#
# Copyright (c) 1992-1994 The Regents of the University of California.
# Copyright (c) 1994 Sun Microsystems, Inc.
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.

package Tk::Text; 
require Tk;
require DynaLoader;
use AutoLoader;
use Carp;

@ISA = qw(DynaLoader Tk::Widget);

Tk::Widget->Construct('Text');

bootstrap Tk::Text;

sub Tk_cmd { \&Tk::text }

import Tk qw(Ev);

1;

__END__

#
# Bind --
# This procedure below invoked the first time the mouse enters a text
# widget or a text widget receives the input focus. It creates all of
# the class bindings for texts.
#
# Arguments:
# event - Indicates which event caused the procedure to be invoked
# (Enter or FocusIn). It is used so that we can carry out
# the functions of that event in addition to setting up
# bindings.

sub bindRdOnly
{
 my ($class,$mw) = @_;

 # Standard Motif bindings:
 $mw->bind($class,"<1>",
            sub
            {
             my $w = shift;
             my $Ev = $w->XEvent;
             $w->Button1($Ev->x,$Ev->y);
             $w->tag("remove","sel","0.0","end")
            }
           )
 ;
 $mw->bind($class,"<B1-Motion>",
            sub
            {
             my $w = shift;
             my $Ev = $w->XEvent;
             $Tk::x = $Ev->x;
             $Tk::y = $Ev->y;
             $w->SelectTo($Ev->xy)
            }
           )
 ;
 $mw->bind($class,"<Double-1>",
            sub
            {
             my $w = shift;
             my $Ev = $w->XEvent;
             $w->SelectTo($Ev->xy,"word");
             eval { $w->mark("set","insert","sel.first") }
            }
           )
 ;
 $mw->bind($class,"<Triple-1>",
            sub
            {
             my $w = shift;
             my $Ev = $w->XEvent;
             $w->SelectTo($Ev->xy,"line");
             eval { $w->mark("set","insert","sel.first") };
            }
           )
 ;
 $mw->bind($class,"<Shift-1>",
            sub
            {
             my $w = shift;
             my $Ev = $w->XEvent;
             $w->ResetAnchor($Ev->xy);
             $w->SelectTo($Ev->xy,"char")
            }
           )
 ;
 $mw->bind($class,"<Double-Shift-1>",['SelectTo',Ev('@%x,%y'),"word"]);
 $mw->bind($class,"<Triple-Shift-1>",['SelectTo',Ev('@%x,%y'),"line"]);

 $mw->bind($class,"<B1-Leave>",
            sub
            {
             my $w = shift;
             my $Ev = $w->XEvent;
             $Tk::x = $Ev->x;
             $Tk::y = $Ev->y;
             $w->AutoScan;
            }
           )
 ;

 $mw->bind($class,"<B1-Enter>",'CancelRepeat');
 $mw->bind($class,"<ButtonRelease-1>",'CancelRepeat');
 $mw->bind($class,"<Control-1>",["mark","set","insert",Ev('@%x,%y')]);
 $mw->bind($class,"<Left>",['SetCursor',Ev("index","insert-1c")]);
 $mw->bind($class,"<Shift-Left>",['KeySelect',Ev("index","insert-1c")]);
 $mw->bind($class,"<Right>",['SetCursor',Ev("index","insert+1c")]);
 $mw->bind($class,"<Shift-Right>",['KeySelect',Ev("index","insert+1c")]);
 $mw->bind($class,"<Up>",['SetCursor',Ev('UpDownLine',-1)]);
 $mw->bind($class,"<Shift-Up>",['KeySelect',Ev('UpDownLine',-1)]);
 $mw->bind($class,"<Down>",['SetCursor',Ev('UpDownLine',1)]);
 $mw->bind($class,"<Shift-Down>",['KeySelect',Ev('UpDownLine',1)]);
 $mw->bind($class,"<Control-Left>",['SetCursor',Ev("index","insert-1c","wordstart")]);
 $mw->bind($class,"<Control-Right>",['SetCursor',Ev("index","insert+1c","wordend")]);
 $mw->bind($class,"<Control-Up>",['SetCursor',Ev('PrevPara',"insert")]);
 $mw->bind($class,"<Control-Down>",['SetCursor',Ev('NextPara',"insert")]);
 $mw->bind($class,"<Shift-Control-Left>",['KeySelect',Ev("index","insert-1c","wordstart")]);
 $mw->bind($class,"<Shift-Control-Right>",['KeySelect',Ev("index","insert","wordend")]);
 $mw->bind($class,"<Shift-Control-Up>",['KeySelect',Ev('PrevPara',"insert")]);
 $mw->bind($class,"<Shift-Control-Down>",['KeySelect',Ev('NextPara',"insert")]);
 $mw->bind($class,"<Prior>",['SetCursor',Ev('ScrollPages',-1)]);
 $mw->bind($class,"<Shift-Prior>",['KeySelect',Ev('ScrollPages',-1)]);
 $mw->bind($class,"<Next>",['SetCursor',Ev('ScrollPages',1)]);
 $mw->bind($class,"<Shift-Next>",['KeySelect',Ev('ScrollPages',1)]);
 $mw->bind($class,"<Control-Prior>",["xview","scroll",-1,"page"]);
 $mw->bind($class,"<Control-Next>",["xview","scroll",1,"page"]);
 $mw->bind($class,"<Home>",['SetCursor',"insert","linestart"]);
 $mw->bind($class,"<Shift-Home>",['KeySelect',"insert","linestart"]);
 $mw->bind($class,"<End>",['SetCursor',"insert","lineend"]);
 $mw->bind($class,"<Shift-End>",['KeySelect',"insert","lineend"]);
 $mw->bind($class,"<Control-Home>",['SetCursor',"1.0"]);
 $mw->bind($class,"<Control-Shift-Home>",['KeySelect',"1.0"]);
 $mw->bind($class,"<Control-End>",['SetCursor',"end-1char"]);
 $mw->bind($class,"<Control-Shift-End>",['KeySelect',"end-1char"]);

 $mw->bind($class,"<Shift-Tab>", 'NoOp'); # Needed only to keep <Tab> binding from triggering; does not have to actually do anything.
 $mw->bind($class,"<Control-Tab>",'focusNext');
 $mw->bind($class,"<Control-Shift-Tab>",'focusPrev');

 $mw->bind($class,"<Control-space>",["mark","set","anchor","insert"]);
 $mw->bind($class,"<Select>",["mark","set","anchor","insert"]);
 $mw->bind($class,"<Control-Shift-space>",['SelectTo',"insert","char"]);
 $mw->bind($class,"<Shift-Select>",['SelectTo',"insert","char"]);
 $mw->bind($class,"<Control-slash>",["tag","add","sel","1.0","end"]);
 $mw->bind($class,"<Control-backslash>",["tag","remove","sel","1.0","end"]);

 if (!$Tk::tk_strictMotif)
  {
   $mw->bind($class,"<Control-a>",    ['SetCursor',"insert linestart"]);
   $mw->bind($class,"<Control-b>",    ['SetCursor',"insert-1c"]);
   $mw->bind($class,"<Control-e>",    ['SetCursor',"insert lineend"]);
   $mw->bind($class,"<Control-f>",    ['SetCursor',"insert+1c"]);
   $mw->bind($class,"<Meta-b>",       ['SetCursor',"insert-1c wordstart"]);
   $mw->bind($class,"<Meta-f>",       ['SetCursor',"insert wordend"]);
   $mw->bind($class,"<Meta-less>",    ['SetCursor',"1.0"]);
   $mw->bind($class,"<Meta-greater>", ['SetCursor',"end-1c"]);

   $mw->bind($class,"<Control-n>",    ['SetCursor',Ev('UpDownLine',1)]);
   $mw->bind($class,"<Control-p>",    ['SetCursor',Ev('UpDownLine',-1)]);

   $mw->bind($class,"<2>",
              sub
              {
               my $w = shift;
               my $Ev = $w->XEvent;
               $w->scan("mark",$Ev->x,$Ev->y);
               $Tk::x = $Ev->x;
               $Tk::y = $Ev->y;
               $Tk::mouseMoved = 0
              }
             )
   ;
   $mw->bind($class,"<B2-Motion>",
              sub
              {
               my $w = shift;
               my $Ev = $w->XEvent;
               if ($Ev->x != $Tk::x || $Ev->y != $Tk::y)
                {
                 $Tk::mouseMoved = 1
                }
               if ($Tk::mouseMoved)
                {
                 $w->scan("dragto",$Ev->x,$Ev->y)
                }
              }
             );

  }

 return $class;
}
                                         

sub classinit
{
 my ($class,$mw) = @_;

 $class->bindRdOnly($mw);

 $mw->bind($class,"<Tab>", sub { my $w = shift; $w->Insert("\t"); $w->focus; $w->break});

 $mw->bind($class,"<Control-i>", ['Insert',"\t"]);
 $mw->bind($class,"<Return>", ['Insert',"\n"]);
 $mw->bind($class,"<Delete>",'Delete');
 $mw->bind($class,"<BackSpace>",'Backspace');

 $class->ClipKeysyms($mw,"F16","F20","F18");

 $mw->bind($class,"<Insert>",
            sub
            {
             my $w = shift;
             eval { $w->Insert($w->SelectionGet) }
            }
           )
 ;
 $mw->bind($class,"<KeyPress>",['Insert',Ev('A')]);
 # Additional emacs-like bindings:

 if (!$Tk::tk_strictMotif)
  {

   $mw->bind($class,"<Control-d>",['delete','insert']);
   $mw->bind($class,"<Control-k>",
              sub
              {
               my $w = shift;
               if ($w->compare("insert","==","insert lineend"))
                {
                 $w->delete("insert")
                }
               else
                {
                 $w->delete("insert","insert lineend")
                }
              }
             )
   ;
   $mw->bind($class,"<Control-o>",
              sub
              {
               my $w = shift;
               $w->insert("insert","\n");
               $w->mark("set","insert","insert-1c")
              }
             )
   ;
   $mw->bind($class,"<Control-t>",
              sub
              {
               my $w = shift;
               $w->insert("insert+2c",$w->get("insert"));
               $w->delete("insert");
               $w->see("insert")
              }
             )
   ;
   $mw->bind($class,"<Meta-d>",['delete','insert','insert wordend']);
   $mw->bind($class,"<Meta-BackSpace>",['delete','insert-1c wordstart','insert']);

   $class->ClipKeysyms($mw,"Meta-w","Control-w","Control-y");
   # A few additional bindings of my own.
   $mw->bind($class,"<Control-h>",
              sub
              {
               my $w = shift;
               if ($w->compare("insert","!=","1.0"))
                {
                 $w->delete("insert-1c");
                 $w->see("insert")
                }
              }
             )
   ;
   $mw->bind($class,"<Control-v>",
              sub
              {
               my $w = shift;
               eval
                {
                 $w->insert("insert",$w->SelectionGet);
                 $w->see("insert")
                }
              }
             )
   ;
   $mw->bind($class,"<Control-x>",
              sub
              {
               my $w = shift;
               eval { $w->delete("sel.first","sel.last") }
              }
             )
   ;
   $mw->bind($class,"<ButtonRelease-2>",
              sub
              {
               my $w = shift;
               my $Ev = $w->XEvent;
               if (!$Tk::mouseMoved)
                {
                 eval
                  {
                   $w->insert($Ev->xy,$w->SelectionGet);
                  }
                }
              }
             )


  }
 $Tk::prevPos = undef;
 return $class;
}

sub Backspace
{
 my $w = shift;
 my $sel = eval { $w->tag("nextrange","sel","1.0","end") };
 if (defined $sel)
  {
   $w->delete("sel.first","sel.last")
  }
 elsif ($w->compare("insert","!=","1.0"))
  {
   $w->delete("insert-1c");
   $w->see("insert")
  }
}

sub Delete
{
 my $w = shift;
 my $sel = eval { $w->tag("nextrange","sel","1.0","end") };
 if (defined $sel)
  {
   $w->delete("sel.first","sel.last")
  }
 else
  {
   $w->delete("insert");
   $w->see("insert")
  }
}

# ClipKeysyms --
# This procedure is invoked to identify the keys that correspond to
# the "copy", "cut", and "paste" functions for the clipboard.
#
# Arguments:
# copy - Name of the key (keysym name plus modifiers, if any,
# such as "Meta-y") used for the copy operation.
# cut - Name of the key used for the cut operation.
# paste - Name of the key used for the paste operation.

sub ClipCopy
{
 my $w = shift;
 if ($w->IS($w->SelectionOwner))
  {
   $w->Clipboard("clear");
   $w->Clipboard("append",$w->SelectionGet)
  }
}

sub ClipCut
{
 my $w = shift;
 if ($w->IS($w->SelectionOwner))
  {
   $w->Clipboard("clear");
   $w->Clipboard("append",$w->SelectionGet);
   $w->delete("sel.first","sel.last")
  }
}

sub ClipPaste
{
 my $w = shift;
 local ($@);
 eval {$w->insert("insert",$w->SelectionGet("-selection","CLIPBOARD"))};
 carp("$@") if ($@);
}

sub ClipKeysyms
{
 my $class = shift;
 my $mw    = shift;
 if (@_)
  {
   my $copy  = shift;
   $mw->bind($class,"<$copy>",'ClipCopy')   if (defined $copy);
  }
 if (@_)
  {
   my $cut   = shift;
   $mw->bind($class,"<$cut>",'ClipCut')     if (defined $cut);
  }
 if (@_)
  {
   my $paste = shift;                                                
   $mw->bind($class,"<$paste>",'ClipPaste') if (defined $paste);
  }
}

# Button1 --
# This procedure is invoked to handle button-1 presses in text
# widgets. It moves the insertion cursor, sets the selection anchor,
# and claims the input focus.
#
# Arguments:
# w - The text window in which the button was pressed.
# x - The x-coordinate of the button press.
# y - The x-coordinate of the button press.
sub Button1
{
 my $w = shift;
 my $x = shift;
 my $y = shift;
 $Tk::selectMode = "char";
 $Tk::mouseMoved = 0;
 $w->mark("set","insert","@".$x.",".$y);
 $w->mark("set","anchor","insert");
 if ($w->cget("-state") eq "normal")
  {
   $w->focus()
  }
}
# SelectTo --
# This procedure is invoked to extend the selection, typically when
# dragging it with the mouse. Depending on the selection mode (character,
# word, line) it selects in different-sized units. This procedure
# ignores mouse motions initially until the mouse has moved from
# one character to another or until there have been multiple clicks.
#
# Arguments:
# w - The text window in which the button was pressed.
# index - Index of character at which the mouse button was pressed.
sub SelectTo
{
 my $w = shift;
 my $index = shift;
 $Tk::selectMode = shift if (@_);
 my $cur = $w->index($index);
 my $anchor = $w->index("anchor");
 if (!defined $anchor)
  {
   $w->mark("set","anchor",$anchor = $cur)
  }
 elsif ($w->compare($cur,"!=",$anchor))
  {
   $Tk::mouseMoved = 1
  }
 my $mode = $Tk::selectMode;
 if ($mode eq "char")
  {
   if ($w->compare($cur,"<","anchor"))
    {
     $first = $cur;
     $last = "anchor";
    }
   else
    {
     $first = "anchor";
     $last = $cur
    }
  }
 elsif ($mode eq "word")
  {
   if ($w->compare($cur,"<","anchor"))
    {
     $first = $w->index("$cur wordstart");
     $last = $w->index("anchor - 1c wordend")
    }
   else
    {
     $first = $w->index("anchor wordstart");
     $last = $w->index("$cur wordend")
    }
  }
 elsif ($mode eq "line")
  {
   if ($w->compare($cur,"<","anchor"))
    {
     $first = $w->index("$cur linestart");
     $last = $w->index("anchor - 1c lineend + 1c")
    }
   else
    {
     $first = $w->index("anchor linestart");
     $last = $w->index("$cur lineend + 1c")
    }
  }
 if ($Tk::mouseMoved || $Tk::selectMode ne "char")
  {
   $w->tag("remove","sel","0.0",$first);
   $w->tag("add","sel",$first,$last);
   $w->tag("remove","sel",$last,"end");
   $w->idletasks;
  }
}
# AutoScan --
# This procedure is invoked when the mouse leaves a text window
# with button 1 down. It scrolls the window up, down, left, or right,
# depending on where the mouse is (this information was saved in
# tkPriv(x) and tkPriv(y)), and reschedules itself as an "after"
# command so that the window continues to scroll until the mouse
# moves back into the window or the mouse button is released.
#
# Arguments:
# w - The text window.
sub AutoScan
{
 my $w = shift;
 if ($Tk::y >= $w->height)
  {
   $w->yview("scroll",2,"units")
  }
 elsif ($Tk::y < 0)
  {
   $w->yview("scroll",-2,"units")
  }
 elsif ($Tk::x >= $w->width)
  {
   $w->xview("scroll",2,"units")
  }
 elsif ($Tk::x < 0)
  {
   $w->xview("scroll",-2,"units")
  }
 else
  {
   return;
  }
 $w->SelectTo("@" . $Tk::x . ",". $Tk::y);
 $w->afterId($w->after(50,"AutoScan",$w));
}
# SetCursor
# Move the insertion cursor to a given position in a text. Also
# clears the selection, if there is one in the text, and makes sure
# that the insertion cursor is visible.
#
# Arguments:
# w - The text window.
# pos - The desired new position for the cursor in the window.
sub SetCursor
{
 my $w = shift;
 my $pos = shift;
 $pos = "end - 1 chars" if $w->compare($pos,"==","end");
 $w->mark("set","insert",$pos);
 $w->tag("remove","sel","1.0","end");
 $w->see("insert")
}
# KeySelect
# This procedure is invoked when stroking out selections using the
# keyboard. It moves the cursor to a new position, then extends
# the selection to that position.
#
# Arguments:
# w - The text window.
# new - A new position for the insertion cursor (the cursor has not
# actually been moved to this position yet).
sub KeySelect
{
 my $w = shift;
 my $new = shift;
 my ($first,$last);
 if (!defined $w->tag("nextrange","sel","1.0","end"))
  {
   if ($w->compare($new,"<","insert"))
    {
     $w->tag("add","sel",$new,"insert")
    }
   else
    {
     $w->tag("add","sel","insert",$new)
    }
  }
 else
  {
   if ($w->compare($new,"<","anchor"))
    {
     $first = $new;
     $last = "anchor"
    }
   else
    {
     $first = "anchor";
     $last = $new
    }
   $w->tag("remove","sel","1.0",$first);
   $w->tag("add","sel",$first,$last);
   $w->tag("remove","sel",$last,"end")
  }
 $w->mark("set","insert",$new);
 $w->see("insert");
 $w->idletasks;
}
# ResetAnchor --
# Set the selection anchor to whichever end is farthest from the
# index argument. One special trick: if the selection has two or
# fewer characters, just leave the anchor where it is. In this
# case it does not matter which point gets chosen for the anchor,
# and for the things like Shift-Left and Shift-Right this produces
# better behavior when the cursor moves back and forth across the
# anchor.
#
# Arguments:
# w - The text widget.
# index - Position at which mouse button was pressed, which determines
# which end of selection should be used as anchor point.
sub ResetAnchor
{
 my $w = shift;
 my $index = shift;
 if (!defined $w->tag("ranges","sel"))
  {
   $w->mark("set","anchor",$index);
   return;
  }
 my $a = $w->index($index);
 my $b = $w->index("sel.first");
 my $c = $w->index("sel.last");
 if ($w->compare($a,"<",$b))
  {
   $w->mark("set","anchor","sel.last");
   return;
  }
 if ($w->compare($a,">",$c))
  {
   $w->mark("set","anchor","sel.first");
   return;
  }
 my ($lineA,$chA) = split(/\./,$a);
 my ($lineB,$chB) = split(/\./,$b);
 my ($lineC,$chC) = split(/\./,$c);
 if ($lineB < $lineC+2)
  {
   $total = length($w->get($b,$c));
   if ($total <= 2)
    {
     return;
    }
   if (length($w->get($b,$a)) < $total/2)
    {
     $w->mark("set","anchor","sel.last")
    }
   else
    {
     $w->mark("set","anchor","sel.first")
    }
   return;
  }
 if ($lineA-$lineB < $lineC-$lineA)
  {
   $w->mark("set","anchor","sel.last")
  }
 else
  {
   $w->mark("set","anchor","sel.first")
  }
}
# Insert --
# Insert a string into a text at the point of the insertion cursor.
# If there is a selection in the text, and it covers the point of the
# insertion cursor, then delete the selection before inserting.
#
# Arguments:
# w - The text window in which to insert the string
# s - The string to insert (usually just a single character)
sub Insert
{
 my $w = shift;
 my $s = shift;
 return unless (defined $s && $s ne "");
 eval
  {
   if ($w->compare("sel.first","<=","insert") && 
       $w->compare("sel.last",">=","insert"))
     {
      $w->delete("sel.first","sel.last")
     }
  };
 $w->insert("insert",$s);
 $w->see("insert")
}
# UpDownLine --
# Returns the index of the character one line above or below the
# insertion cursor. There are two tricky things here. First,
# we want to maintain the original column across repeated operations,
# even though some lines that will get passed through do not have
# enough characters to cover the original column. Second, do not
# try to scroll past the beginning or end of the text.
#
# Arguments:
# w - The text window in which the cursor is to move.
# n - The number of lines to move: -1 for up one line,
# +1 for down one line.
sub UpDownLine
{
 my $w = shift;
 my $n = shift;
 my $i = $w->index("insert");
 my ($line,$char) = split(/\./,$i);
 if (!defined $Tk::prevPos || ($Tk::prevPos cmp $i) != 0)
  {
   $Tk::char = $char
  }
 my $new = $w->index($line+$n . "." . $Tk::char);
 if ($w->compare($new,"==","end") || $w->compare($new,"==","insert linestart"))
  {
   $new = $i
  }
 $Tk::prevPos = $new;
 return $new;
}
# PrevPara --
# Returns the index of the beginning of the paragraph just before a given
# position in the text (the beginning of a paragraph is the first non-blank
# character after a blank line).
#
# Arguments:
# w - The text window in which the cursor is to move.
# pos - Position at which to start search.
sub PrevPara
{
 my $w = shift;
 my $pos = shift;
 $pos = $w->index("$pos linestart");
 while (1)
  {
   if ($w->get("$pos - 1 line") eq "\n" && $w->get($pos) ne "\n" || $pos eq "1.0" )
    {
     my $string = $w->get($pos,"$pos lineend");
     if ($string =~ /^(\s)+/)
      {
       my $off = length($1);
       $pos = $w->index("$pos + $off chars")
      }
     if ($w->compare($pos,"!=","insert") || $pos eq "1.0")
      {
       return $pos;
      }
    }
   $pos = $w->index("$pos - 1 line")
  }
}
# NextPara --
# Returns the index of the beginning of the paragraph just after a given
# position in the text (the beginning of a paragraph is the first non-blank
# character after a blank line).
#
# Arguments:
# w - The text window in which the cursor is to move.
# start - Position at which to start search.
sub NextPara
{
 my $w = shift;
 my $start = shift;
 $pos = $w->index("$start linestart + 1 line");
 while ($w->get($pos) ne "\n")
  {
   if ($w->compare($pos,"==","end"))
    {
     return $w->index("end - 1c");
    }
   $pos = $w->index("$pos + 1 line")
  }
 while ($w->get($pos) eq "\n" )
  {
   $pos = $w->index("$pos + 1 line");
   if ($w->compare($pos,"==","end"))
    {
     return $w->index("end - 1c");
    }
  }
 my $string = $w->get($pos,"$pos lineend");
 if ($string =~ /^(\s+)/)
  {
   my $off = length($1);
   return $w->index("$pos + $off chars");
  }
 return $pos;
}
# ScrollPages --
# This is a utility procedure used in bindings for moving up and down
# pages and possibly extending the selection along the way. It scrolls
# the view in the widget by the number of pages, and it returns the
# index of the character that is at the same position in the new view
# as the insertion cursor used to be in the old view.
#
# Arguments:
# w - The text window in which the cursor is to move.
# count - Number of pages forward to scroll; may be negative
# to scroll backwards.
sub ScrollPages
{
 my $w = shift;
 my $count = shift;
 my @bbox = $w->bbox("insert");
 $w->yview("scroll",$count,"pages");
 if (!@bbox)
  {
   return $w->index("@" . int($w->height/2) . "," . 0);
  }
 $x = int($bbox[0]+$bbox[2]/2);
 $y = int($bbox[1]+$bbox[3]/2);
 return $w->index("@" . $x . "," . $y);
}

sub Contents
{
 my $w = shift;
 if (@_)
  {
   $w->delete('1.0','end');
   $w->insert('end',shift);
  }
 else
  {
   return $w->get('1.0','end');
  }
}
