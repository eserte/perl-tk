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

require Tk;
package Tk::Text; 
use AutoLoader;
use Carp;
use strict;

use vars qw($VERSION @ISA);
$VERSION = '3.005'; # $Id: //depot/Tk8/Text/Text.pm#5$

@ISA = qw(Tk::Widget);

Construct Tk::Widget 'Text';

bootstrap Tk::Text $Tk::VERSION;

sub Tk_cmd { \&Tk::text }

import Tk qw(Ev);

sub Tk::Widget::ScrlText { shift->Scrolled('Text' => @_) }

Tk::Methods("bbox","compare","debug","delete","dlineinfo","dump",
            "get","image","index","insert","mark","scan","search",
            "see","tag","window","xview","yview");

use Tk::Submethods ( 'mark' => [qw(gravity names next previous set unset)],
                     'scan' => [qw(mark dragto)],
                     'tag'  => [qw(add bind cget configure delete lower 
                               names nextrange prevrange raise ranges remove)],
                     'window' => [qw(cget configure create names)]
                   );

sub Tag;
sub Tags;

1;

__END__


sub bindRdOnly
{
 require Tk::Clipboard;

 my ($class,$mw) = @_;

 # Standard Motif bindings:
 $mw->bind($class,"<1>",['Button1',Ev('x'),Ev('y')]);
 $mw->bind($class,"<Meta-B1-Motion>",'NoOp');
 $mw->bind($class,"<Meta-1>",'NoOp');
 $mw->bind($class,'<Alt-KeyPress>','NoOp');
 $mw->bind($class,'<Escape>',['tag','remove','sel','1.0','end']);

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
             $w->SelectTo($Ev->xy,'word');
             Tk::catch { $w->markSet('insert',"sel.first") }
            }
           )
 ;
 $mw->bind($class,"<Triple-1>",
            sub
            {
             my $w = shift;
             my $Ev = $w->XEvent;
             $w->SelectTo($Ev->xy,'line');
             Tk::catch { $w->markSet('insert',"sel.first") };
            }
           )
 ;
 $mw->bind($class,"<Shift-1>",
            sub
            {
             my $w = shift;
             my $Ev = $w->XEvent;
             $w->ResetAnchor($Ev->xy);
             $w->SelectTo($Ev->xy,'char')
            }
           )
 ;
 $mw->bind($class,"<Double-Shift-1>",['SelectTo',Ev('@'),'word']);
 $mw->bind($class,"<Triple-Shift-1>",['SelectTo',Ev('@'),'line']);

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
 $mw->bind($class,"<Control-1>",["markSet",'insert',Ev('@')]);

 $mw->bind($class,"<Left>",['SetCursor',Ev('index',"insert-1c")]);
 $mw->bind($class,"<Shift-Left>",['KeySelect',Ev('index',"insert-1c")]);
 $mw->bind($class,"<Control-Left>",['SetCursor',Ev('index',"insert-1c wordstart")]);
 $mw->bind($class,"<Shift-Control-Left>",['KeySelect',Ev('index',"insert-1c wordstart")]);

 $mw->bind($class,"<Right>",['SetCursor',Ev('index',"insert+1c")]);
 $mw->bind($class,"<Shift-Right>",['KeySelect',Ev('index',"insert+1c")]);
 $mw->bind($class,"<Control-Right>",['SetCursor',Ev('index',"insert+1c wordend")]);
 $mw->bind($class,"<Shift-Control-Right>",['KeySelect',Ev('index',"insert wordend")]);

 $mw->bind($class,"<Up>",['SetCursor',Ev('UpDownLine',-1)]);
 $mw->bind($class,"<Shift-Up>",['KeySelect',Ev('UpDownLine',-1)]);
 $mw->bind($class,"<Control-Up>",['SetCursor',Ev('PrevPara','insert')]);
 $mw->bind($class,"<Shift-Control-Up>",['KeySelect',Ev('PrevPara','insert')]);

 $mw->bind($class,"<Down>",['SetCursor',Ev('UpDownLine',1)]);
 $mw->bind($class,"<Shift-Down>",['KeySelect',Ev('UpDownLine',1)]);
 $mw->bind($class,"<Control-Down>",['SetCursor',Ev('NextPara','insert')]);
 $mw->bind($class,"<Shift-Control-Down>",['KeySelect',Ev('NextPara','insert')]);

 $mw->bind($class,"<Home>",['SetCursor',"insert linestart"]);
 $mw->bind($class,"<Shift-Home>",['KeySelect',"insert linestart"]);
 $mw->bind($class,"<Control-Home>",['SetCursor','1.0']);
 $mw->bind($class,"<Control-Shift-Home>",['KeySelect','1.0']);

 $mw->bind($class,"<End>",['SetCursor',"insert lineend"]);
 $mw->bind($class,"<Shift-End>",['KeySelect',"insert lineend"]);
 $mw->bind($class,"<Control-End>",['SetCursor',"end-1char"]);
 $mw->bind($class,"<Control-Shift-End>",['KeySelect',"end-1char"]);

 $mw->bind($class,"<Prior>",['SetCursor',Ev('ScrollPages',-1)]);
 $mw->bind($class,"<Shift-Prior>",['KeySelect',Ev('ScrollPages',-1)]);
 $mw->bind($class,"<Control-Prior>",['xview','scroll',-1,'page']);

 $mw->bind($class,"<Next>",['SetCursor',Ev('ScrollPages',1)]);
 $mw->bind($class,"<Shift-Next>",['KeySelect',Ev('ScrollPages',1)]);
 $mw->bind($class,"<Control-Next>",['xview','scroll',1,'page']);

 $mw->bind($class,"<Shift-Tab>", 'NoOp'); # Needed only to keep <Tab> binding from triggering; does not have to actually do anything.
 $mw->bind($class,"<Control-Tab>",'focusNext');
 $mw->bind($class,"<Control-Shift-Tab>",'focusPrev');

 $mw->bind($class,"<Control-space>",["markSet",'anchor','insert']);
 $mw->bind($class,"<Select>",["markSet",'anchor','insert']);
 $mw->bind($class,"<Control-Shift-space>",['SelectTo','insert','char']);
 $mw->bind($class,"<Shift-Select>",['SelectTo','insert','char']);
 $mw->bind($class,"<Control-slash>",['tag','add','sel','1.0','end']);
 $mw->bind($class,"<Control-backslash>",['tag','remove','sel','1.0','end']);

 if (!$Tk::strictMotif)
  {
   $mw->bind($class,"<Control-a>",    ['SetCursor',"insert linestart"]);
   $mw->bind($class,"<Control-b>",    ['SetCursor',"insert-1c"]);
   $mw->bind($class,"<Control-e>",    ['SetCursor',"insert lineend"]);
   $mw->bind($class,"<Control-f>",    ['SetCursor',"insert+1c"]);
   $mw->bind($class,"<Meta-b>",       ['SetCursor',"insert-1c wordstart"]);
   $mw->bind($class,"<Meta-f>",       ['SetCursor',"insert wordend"]);
   $mw->bind($class,"<Meta-less>",    ['SetCursor','1.0']);
   $mw->bind($class,"<Meta-greater>", ['SetCursor',"end-1c"]);

   $mw->bind($class,"<Control-n>",    ['SetCursor',Ev('UpDownLine',1)]);
   $mw->bind($class,"<Control-p>",    ['SetCursor',Ev('UpDownLine',-1)]);

   $mw->bind($class,"<2>",['Button2',Ev('x'),Ev('y')]);
   $mw->bind($class,"<B2-Motion>",['Motion2',Ev('x'),Ev('y')]);

   $class->clipboardKeysyms($mw,"F16");
   $class->clipboardKeysyms($mw,'Control-c');
  }
 $mw->bind($class,"<Destroy>",'Destroy');
 return $class;
}


sub Motion2
{
 my ($w,$x,$y) = @_;
 $Tk::mouseMoved = 1 if ($x != $Tk::x || $y != $Tk::y);
 $w->scan('dragto',$x,$y) if ($Tk::mouseMoved);
}

sub Button2
{
 my ($w,$x,$y) = @_;
 $w->scan('mark',$x,$y);
 $Tk::x = $x;
 $Tk::y = $y;
 $Tk::mouseMoved = 0;
}
                                         

sub ClassInit
{
 my ($class,$mw) = @_;

 $class->bindRdOnly($mw);

 $mw->bind($class,"<Tab>", sub { my $w = shift; $w->Insert("\t"); $w->focus; $w->break});

 $mw->bind($class,"<Control-i>", ['Insert',"\t"]);
 $mw->bind($class,"<Return>", ['Insert',"\n"]);
 $mw->bind($class,"<Delete>",'Delete');
 $mw->bind($class,"<BackSpace>",'Backspace');

 $class->clipboardKeysyms($mw,"F16","F20","F18");
 $class->clipboardKeysyms($mw,'Control-c','Control-x','Control-v');

 $mw->bind($class,"<Insert>",
            sub
            {
             my $w = shift;
             Tk::catch { $w->Insert($w->SelectionGet) }
            }
           )
 ;
 $mw->bind($class,"<KeyPress>",['Insert',Ev('A')]);
 # Additional emacs-like bindings:

 if (!$Tk::strictMotif)
  {

   $mw->bind($class,"<Control-d>",['delete','insert']);
   $mw->bind($class,"<Control-k>",
              sub
              {
               my $w = shift;
               if ($w->compare('insert',"==","insert lineend"))
                {
                 $w->delete('insert')
                }
               else
                {
                 $w->delete('insert',"insert lineend")
                }
              }
             )
   ;
   $mw->bind($class,"<Control-o>",
              sub
              {
               my $w = shift;
               $w->insert('insert',"\n");
               $w->markSet('insert',"insert-1c")
              }
             )
   ;
   $mw->bind($class,"<Control-t>",'Transpose');
   $mw->bind($class,"<Meta-d>",['delete','insert','insert wordend']);
   $mw->bind($class,"<Meta-BackSpace>",['delete','insert-1c wordstart','insert']);

   $class->clipboardKeysyms($mw,"Meta-w","Control-w","Control-y");
   # A few additional bindings of my own.
   $mw->bind($class,"<Control-h>",
              sub
              {
               my $w = shift;
               if ($w->compare('insert',"!=",'1.0'))
                {
                 $w->delete("insert-1c");
                 $w->see('insert')
                }
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
                 Tk::catch
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
 my $sel = Tk::catch { $w->tag('nextrange','sel','1.0','end') };
 if (defined $sel)
  {
   $w->delete('sel.first','sel.last')
  }
 elsif ($w->compare('insert',"!=",'1.0'))
  {
   $w->delete("insert-1c");
   $w->see('insert')
  }
}

sub Delete
{
 my $w = shift;
 my $sel = Tk::catch { $w->tag('nextrange','sel','1.0','end') };
 if (defined $sel)
  {
   $w->delete("sel.first","sel.last")
  }
 else
  {
   $w->delete('insert');
   $w->see('insert')
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
 $Tk::selectMode = 'char';
 $Tk::mouseMoved = 0;
 $w->markSet('insert',"@".$x.",".$y);
 $w->markSet('anchor','insert');
 $w->focus() if ($w->cget("-state") eq 'normal');
 $w->tag('remove','sel','1.0','end');
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
 my $anchor = Tk::catch { $w->index('anchor') };
 if (!defined $anchor)
  {
   $w->markSet('anchor',$anchor = $cur);
   $Tk::mouseMoved = 0;
  }
 elsif ($w->compare($cur,"!=",$anchor))
  {
   $Tk::mouseMoved = 1;
  }
 $Tk::selectMode = 'char' unless (defined $Tk::selectMode);
 my $mode = $Tk::selectMode;
 my ($first,$last);
 if ($mode eq 'char')
  {
   if ($w->compare($cur,"<",'anchor'))
    {
     $first = $cur;
     $last = 'anchor';
    }
   else
    {
     $first = 'anchor';
     $last = $cur
    }
  }
 elsif ($mode eq 'word')
  {
   if ($w->compare($cur,"<",'anchor'))
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
 elsif ($mode eq 'line')
  {
   if ($w->compare($cur,"<",'anchor'))
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
 if ($Tk::mouseMoved || $Tk::selectMode ne 'char')
  {
   $w->tag('remove','sel','1.0',$first);
   $w->tag('add','sel',$first,$last);
   $w->tag('remove','sel',$last,'end');
   $w->idletasks;
  }
}
# AutoScan --
# This procedure is invoked when the mouse leaves a text window
# with button 1 down. It scrolls the window up, down, left, or right,
# depending on where the mouse is (this information was saved in
# tkPriv(x) and tkPriv(y)), and reschedules itself as an 'after'
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
   $w->yview('scroll',2,'units')
  }
 elsif ($Tk::y < 0)
  {
   $w->yview('scroll',-2,'units')
  }
 elsif ($Tk::x >= $w->width)
  {
   $w->xview('scroll',2,'units')
  }
 elsif ($Tk::x < 0)
  {
   $w->xview('scroll',-2,'units')
  }
 else
  {
   return;
  }
 $w->SelectTo("@" . $Tk::x . ",". $Tk::y);
 $w->RepeatId($w->after(50,"AutoScan",$w));
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
 $pos = "end - 1 chars" if $w->compare($pos,"==",'end');
 $w->markSet('insert',$pos);
 $w->tag('remove','sel','1.0','end');
 $w->see('insert')
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
 if (!defined $w->tag('ranges','sel'))
  {
   # No selection yet
   $w->markSet('anchor','insert');
   if ($w->compare($new,"<",'insert'))
    {
     $w->tag('add','sel',$new,'insert')
    }
   else
    {
     $w->tag('add','sel','insert',$new)
    }
  }
 else
  {
   # Selection exists
   if ($w->compare($new,"<",'anchor'))
    {
     $first = $new;
     $last = 'anchor'
    }
   else
    {
     $first = 'anchor';
     $last = $new
    }
   $w->tag('remove','sel','1.0',$first);
   $w->tag('add','sel',$first,$last);
   $w->tag('remove','sel',$last,'end')
  }
 $w->markSet('insert',$new);
 $w->see('insert');
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
 if (!defined $w->tag('ranges','sel'))
  {
   $w->markSet('anchor',$index);
   return;
  }
 my $a = $w->index($index);
 my $b = $w->index("sel.first");
 my $c = $w->index("sel.last");
 if ($w->compare($a,"<",$b))
  {
   $w->markSet('anchor',"sel.last");
   return;
  }
 if ($w->compare($a,">",$c))
  {
   $w->markSet('anchor',"sel.first");
   return;
  }
 my ($lineA,$chA) = split(/\./,$a);
 my ($lineB,$chB) = split(/\./,$b);
 my ($lineC,$chC) = split(/\./,$c);
 if ($lineB < $lineC+2)
  {
   my $total = length($w->get($b,$c)); 
   if ($total <= 2)
    {
     return;
    }
   if (length($w->get($b,$a)) < $total/2)
    {
     $w->markSet('anchor',"sel.last")
    }
   else
    {
     $w->markSet('anchor',"sel.first")
    }
   return;
  }
 if ($lineA-$lineB < $lineC-$lineA)
  {
   $w->markSet('anchor',"sel.last")
  }
 else
  {
   $w->markSet('anchor',"sel.first")
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
 return unless (defined $s && $s ne '');
 Tk::catch
  {
   if ($w->compare("sel.first","<=",'insert') && 
       $w->compare("sel.last",">=",'insert'))
     {
      $w->delete("sel.first","sel.last")
     }
  };
 $w->insert('insert',$s);
 $w->see('insert')
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
 my $i = $w->index('insert');
 my ($line,$char) = split(/\./,$i);
 if (!defined($Tk::prevPos) || $Tk::prevPos ne $i)
  {
   $Tk::char = $char
  }
 my $new = $w->index($line+$n . "." . $Tk::char);
 if ($w->compare($new,"==",'end') || $w->compare($new,"==","insert linestart"))
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
   if ($w->get("$pos - 1 line") eq "\n" && $w->get($pos) ne "\n" || $pos eq '1.0' )
    {
     my $string = $w->get($pos,"$pos lineend");
     if ($string =~ /^(\s)+/)
      {
       my $off = length($1);
       $pos = $w->index("$pos + $off chars")
      }
     if ($w->compare($pos,"!=",'insert') || $pos eq '1.0')
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
 my $pos = $w->index("$start linestart + 1 line");
 while ($w->get($pos) ne "\n")
  {
   if ($w->compare($pos,"==",'end'))
    {
     return $w->index("end - 1c");
    }
   $pos = $w->index("$pos + 1 line")
  }
 while ($w->get($pos) eq "\n" )
  {
   $pos = $w->index("$pos + 1 line");
   if ($w->compare($pos,"==",'end'))
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
 my @bbox = $w->bbox('insert');
 $w->yview('scroll',$count,'pages');
 if (!@bbox)
  {
   return $w->index("@" . int($w->height/2) . "," . 0);
  }
 my $x = int($bbox[0]+$bbox[2]/2);
 my $y = int($bbox[1]+$bbox[3]/2);
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

sub Destroy
{
 my $w = shift;
 delete $w->{_Tags_};
}

sub Transpose
{
 my ($w) = @_;
 my $pos = 'insert';
 $pos = $w->index("$pos + 1 char") if ($w->compare($pos,'!=',"$pos lineend"));
 return if ($w->compare("$pos - 1 char",'==','1.0'));
 my $new = $w->get("$pos - 1 char").$w->get("$pos - 2 char");
 $w->delete("$pos - 2 char",$pos);
 $w->insert('insert',$new); 
 $w->see('insert');
}

sub Tag
{
 my $w = shift;
 my $name = shift;
 Carp::confess("No args") unless (ref $w and defined $name);
 $w->{_Tags_} = {} unless (exists $w->{_Tags_});
 unless (exists $w->{_Tags_}{$name})
  {
   require Tk::Text::Tag;
   $w->{_Tags_}{$name} = 'Tk::Text::Tag'->new($w,$name);
  }
 $w->{_Tags_}{$name}->configure(@_) if (@_); 
 return $w->{_Tags_}{$name};
}

sub Tags
{
 my $w = shift;
 my $name;
 my @result = ();
 foreach $name ($w->tagNames(@_))
  {
   push(@result,$w->Tag($name));
  }
 return @result;
}

sub TIEHANDLE
{
 my ($class,$obj) = @_;
 return $obj;
}

sub PRINT
{
 my $w = shift;
 while (@_)
  {
   $w->insert('end',shift);
  }
}

sub PRINTF
{
 my $w = shift;
 $w->PRINT(sprintf(shift,@_));
}

1;
__END__

