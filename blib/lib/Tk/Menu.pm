# Converted from menu.tcl --
#
# This file defines the default bindings for Tk menus and menubuttons.
# It also implements keyboard traversal of menus and implements a few
# other utility procedures related to menus.
#
# @(#) menu.tcl 1.34 94/12/19 17:09:09
#
# Copyright (c) 1992-1994 The Regents of the University of California.
# Copyright (c) 1994 Sun Microsystems, Inc.
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.

package Tk::Menu; 
require Tk;
require Tk::Widget;
require Tk::Wm;
require Tk::Derived;
use AutoLoader;


use vars qw($VERSION);
$VERSION = '2.006'; # $Id: //depot/Tk/Menu/Menu.pm#6$

@ISA = qw(Tk::Wm Tk::Derived Tk::Widget);

Construct Tk::Widget 'Menu';

bootstrap Tk::Menu $Tk::VERSION;

sub Tk_cmd { \&Tk::menu }

import Tk qw(Ev);

sub CreateArgs
{
 my ($package,$parent,$args) = @_;
 # Remove from hash %$args any configure-like
 # options which only apply at create time (e.g. -class for Frame)
 # return these as a list of -key => value pairs
 my @result = ();
 my $opt;
 foreach $opt (qw(-screen -visual -colormap))
  {
   my $val = delete $args->{$opt};                     
   push(@result, $opt => $val) if (defined $val);
  }
 return @result;
}

sub InitObject
{
 my ($menu,$args) = @_;
 my $menuitems = delete $args->{-menuitems};
 $menu->SUPER::InitObject($args);
 if (defined $menuitems)
  {
   # If any other args do configure now
   if (%$args)
    {
     $menu->configure(%$args);
     %$args = ();
    }
   $menu->AddItems(@$menuitems) 
  }
}

sub AddItems
{
 require Tk::Menu::Item;
 my $menu = shift;
 ITEM:
 while (@_)
  {
   my $item = shift;
   if (!ref($item))
    { 
     $menu->separator;  # A separator
    }  
   else
    {
     my ($kind,$name,%minfo) = ( @$item );
     my $invoke = delete $minfo{'-invoke'};
     if (defined $name)
      {
       $minfo{-label} = $name unless defined($minfo{-label});
       $menu->$kind(%minfo);
      }
     else
      {
       $menu->BackTrace("Don't recognize " . join(' ',@$item));
      }
    }  # A non-separator
  }
}
        
1;

__END__

#
#-------------------------------------------------------------------------
# Elements of tkPriv that are used in this file:
#
# cursor - Saves the -cursor option for the posted menubutton.
# focus - Saves the focus during a menu selection operation.
# Focus gets restored here when the menu is unposted.
# inMenubutton - The name of the menubutton widget containing
# the mouse, or an empty string if the mouse is
# not over any menubutton.
# popup - If a menu has been popped up via tk_popup, this
# gives the name of the menu. Otherwise this
# value is empty.
# postedMb - Name of the menubutton whose menu is currently
# posted, or an empty string if nothing is posted
# A grab is set on this widget.
# relief - Used to save the original relief of the current
# menubutton.
# window - When the mouse is over a menu, this holds the
# name of the menu; it's cleared when the mouse
# leaves the menu.
#-------------------------------------------------------------------------
#-------------------------------------------------------------------------
# Overall note:
# This file is tricky because there are four different ways that menus
# can be used:
#
# 1. As a pulldown from a menubutton. This is the most common usage.
# In this style, the variable tkPriv(postedMb) identifies the posted
# menubutton.
# 2. As a torn-off menu copied from some other menu. In this style
# tkPriv(postedMb) is empty, and the top-level menu is no
# override-redirect.
# 3. As an option menu, triggered from an option menubutton. In thi
# style tkPriv(postedMb) identifies the posted menubutton.
# 4. As a popup menu. In this style tkPriv(postedMb) is empty and
# the top-level menu is override-redirect.
#
# The various binding procedures use the state described above to
# distinguish the various cases and take different actions in each
# case.
#-------------------------------------------------------------------------
# Bind --
# This procedure is invoked the first time the mouse enters a menubutton
# widget or a menubutton widget receives the input focus. It creates
# all of the class bindings for both menubuttons and menus.
#
# Arguments:
# w - The widget that was just entered or just received
# the input focus.
# event - Indicates which event caused the procedure to be invoked
# (Enter or FocusIn). It is used so that we can carry out
# the functions of that event in addition to setting up
# bindings.
sub ClassInit
{
 my ($class,$mw) = @_;
 # Must set focus when mouse enters a menu, in order to allow
 # mixed-mode processing using both the mouse and the keyboard.
 $mw->bind($class,"<Enter>", 'Enter');
 $mw->bind($class,"<Leave>", ['Leave',Ev(X),Ev(Y),Ev('s')]);
 $mw->bind($class,"<Motion>", ['Motion',Ev('y'),Ev('s')]);
 $mw->bind($class,"<ButtonPress>",'ButtonDown');
 $mw->bind($class,"<ButtonRelease>",'Invoke');
 $mw->bind($class,"<space>",'Invoke');
 $mw->bind($class,"<Return>",'Invoke');
 $mw->bind($class,"<Escape>",'Escape');
 $mw->bind($class,"<Left>",['LeftRight',"left"]);
 $mw->bind($class,"<Right>",['LeftRight',"right"]);
 $mw->bind($class,"<Up>",['NextEntry',-1]);
 $mw->bind($class,"<Down>",['NextEntry',1]);
 $mw->bind($class,"<KeyPress>", ['TraverseWithinMenu',Ev(A)]);
 return $class;
}

# Unpost --
# This procedure unposts a given menu, plus all of its ancestors up
# to (and including) a menubutton, if any. It also restores various
# values to what they were before the menu was posted, and releases
# a grab if there's a menubutton involved. Special notes:
# 1. It's important to unpost all menus before releasing the grab, so
# that any Enter-Leave events (e.g. from menu back to main
# application) have mode NotifyGrab.
# 2. Be sure to enclose various groups of commands in "catch" so that
# the procedure will complete even if the menubutton or the menu
# or the grab window has been deleted.
#
# Arguments:
# menu - Name of a menu to unpost. Ignored if there
# is a posted menubutton.
sub Unpost
{
 my $menu = shift;
 my $mb = $Tk::postedMb;

 # Restore focus right away (otherwise X will take focus away when
 # the menu is unmapped and under some window managers (e.g. olvwm)
 # we'll lose the focus completely).

 eval {local $SIG{__DIE__}; $Tk::focus->focus() } if (defined $Tk::focus);
 undef $Tk::focus;

 # Unpost menu(s) and restore some stuff that's dependent on
 # what was posted.
 eval {local $SIG{__DIE__}; 
   if (defined $mb)
     {
      $menu = $mb->cget("-menu");
      $menu->unpost();
      $Tk::postedMb = undef;
      $mb->configure("-cursor",$Tk::cursor);
      $mb->configure("-relief",$Tk::relief)
     }
    elsif (defined $Tk::popup)
     {
      $Tk::popup->unpost();
      undef $Tk::popup;
     }
    elsif (defined $menu && ref $menu && $menu->transient)
     {
      # We're in a cascaded sub-menu from a torn-off menu or popup.
      # Unpost all the menus up to the toplevel one (but not
      # including the top-level torn-off one) and deactivate the
      # top-level torn off menu if there is one.
      while (1)
       {
        $parent = $menu->parent;
        last if (!$parent->IsMenu || !$parent->ismapped);
        $parent->postcascade("none");
        last if (!$parent->transient);
        $menu = $parent
       }
      $menu->unpost()
     }
  };
 warn "$@" if ($@);
 # Release grab, if any.
 if (defined $menu && ref $menu)
  {
   my $grab = $menu->grabCurrent;
   $grab->grabRelease if (defined $grab);
  }
}

sub typeIS
{my $w = shift;
 my $type = $w->type(shift);
 return defined $type && $type eq shift;
}

# Motion --
# This procedure is called to handle mouse motion events for menus.
# It does two things. First, it resets the active element in the
# menu, if the mouse is over the menu.  Second, if a mouse button
# is down, it posts and unposts cascade entries to match the mouse
# position.
#
# Arguments:
# menu - The menu window.
# y - The y position of the mouse.
# state - Modifier state (tells whether buttons are down).
sub Motion
{
 my $menu = shift;
 my $y = shift;
 my $state = shift;
 if ($menu->IS($Tk::window))
  {
   $menu->activate("\@$y")
  }
 if (($state & 0x1f00) != 0)
  {
   $menu->postcascade("active")
  }
}
# ButtonDown --
# Handles button presses in menus. There are a couple of tricky things
# here:
# 1. Change the posted cascade entry (if any) to match the mouse position.
# 2. If there is a posted menubutton, must grab to the menubutton so
#    that it can track mouse motions over other menubuttons and change
#    the posted menu.
# 3. If there's no posted menubutton (e.g. because we're a torn-off menu
#    or one of its descendants) must grab to the top-level menu so that
#    we can track mouse motions across the entire menu hierarchy.

#
# Arguments:
# menu - The menu window.
sub ButtonDown
{
 my $menu = shift;
 $menu->postcascade("active");
 if (defined $Tk::postedMb)
  {
   $Tk::postedMb->grabGlobal
  }
 else
  {
   while ($menu->transient
          && $menu->parent->IsMenu
          && $menu->parent->ismapped 
         )
    {
     $menu = $menu->parent;
    }
   $menu->grabGlobal;
  }
}

sub Enter
{
 my $w = shift; 
 $Tk::window = $w; 
 $w->focus();
}

# Leave --
# This procedure is invoked to handle Leave events for a menu. It
# deactivates everything unless the active element is a cascade element
# and the mouse is now over the submenu.
#
# Arguments:
# menu - The menu window.
# rootx, rooty - Root coordinates of mouse.
# state - Modifier state.
sub Leave
{
 my $menu = shift;
 my $rootx = shift;
 my $rooty = shift;
 my $state = shift;
 my $type;
 undef $Tk::window;
 return if ($menu->index("active") eq "none");
 return if ! defined $menu->Containing($rootx,$rooty);
 return if ($menu->typeIS("active","cascade") && 
            $menu->entrycget("active","-menu")->IS($menu->Containing($rootx,$rooty)));
 $menu->activate("none")
}
# Invoke --
# This procedure is invoked when button 1 is released over a menu.
# It invokes the appropriate menu action and unposts the menu if
# it came from a menubutton.
#
# Arguments:
# w - Name of the menu widget.
sub Invoke
{
 my $w = shift;
 my $type = $w->type("active");
 if ($w->typeIS("active","cascade"))
  {
   $w->postcascade("active");
   $menu = $w->entrycget("active","-menu");
   $menu->FirstEntry() if (defined $menu);
  }
 elsif ($w->typeIS("active","tearoff"))
  {
   $w->Unpost();
   $w->TearOffMenu();
  }
 else
  {
   $w->Unpost();
   $w->invoke("active")
  }
}
# Escape --
# This procedure is invoked for the Cancel (or Escape) key. It unposts
# the given menu and, if it is the top-level menu for a menu button,
# unposts the menu button as well.
#
# Arguments:
# menu - Name of the menu window.
sub Escape
{
 my $menu = shift;
 if (!$menu->parent->IsMenu)
  {
   $menu->Unpost()
  }
 else
  {
   $menu->LeftRight(-1)
  }
}
# LeftRight --
# This procedure is invoked to handle "left" and "right" traversal
# motions in menus. It traverses to the next menu in a menu bar,
# or into or out of a cascaded menu.
#
# Arguments:
# menu - The menu that received the keyboard
# event.
# direction - Direction in which to move: "left" or "right"
sub LeftRight
{
 my $menu = shift;
 my $direction = shift;
 # First handle traversals into and out of cascaded menus.
 if ($direction eq "right")
  {
   $count = 1;
   if ($menu->typeIS("active","cascade"))
    {
     $menu->postcascade("active");
     $m2 = $menu->entrycget("active","-menu");
     $m2->FirstEntry if (defined $m2);
     return;
    }
  }
 else
  {
   $count = -1;
   $m2 = $menu->parent;
   if ($m2->IsMenu)
    {
     $menu->activate("none");
     $m2->focus();
     # This code unposts any posted submenu in the parent.
     $tmp = $m2->index("active");
     $m2->activate("none");
     $m2->activate($tmp);
     return;
    }
  }
 # Can't traverse into or out of a cascaded menu. Go to the next
 # or previous menubutton, if that makes sense.
 $w = $Tk::postedMb;
 if ($w eq "")
  {
   return;
  }
 my @buttons = $w->parent->children;
 $length = @buttons;
 $i = Tk::lsearch(\@buttons,$w)+$count;
 while (1)
  {
   while ($i < 0)
    {
     $i += $length
    }
   while ($i >= $length)
    {
     $i += -$length
    }
   $mb = $buttons[$i];
   last if ($mb->IsMenubutton && $mb->cget("-state") ne "disabled"
            && defined($mb->cget('-menu'))
            && $mb->cget('-menu')->index('last') ne 'none'
           );
   return if ($mb == $w);
   $i += $count
  }
 $mb->PostFirst();
}
# NextEntry --
# Activate the next higher or lower entry in the posted menu,
# wrapping around at the ends. Disabled entries are skipped.
#
# Arguments:
# menu - Menu window that received the keystroke.
# count - 1 means go to the next lower entry,
# -1 means go to the next higher entry.
sub NextEntry
{
 my $menu = shift;
 my $count = shift;
 if ($menu->index("last") eq "none")
  {
   return;
  }
 $length = $menu->index("last")+1;
 $active = $menu->index("active");
 if ($active eq "none")
  {
   $i = 0
  }
 else
  {
   $i = $active+$count
  }
 while (1)
  {
   while ($i < 0)
    {
     $i += $length
    }
   while ($i >= $length)
    {
     $i += -$length
    }
   $state = eval {local $SIG{__DIE__};  $menu->entrycget($i,"-state") };
   last if (defined($state) && $state ne "disabled");
   return if ($i == $active);
   $i += $count
  }
 $menu->activate($i);
 $menu->postcascade($i)
}


# tkTraverseWithinMenu
# This procedure implements keyboard traversal within a menu. It
# searches for an entry in the menu that has "char" underlined. If
# such an entry is found, it is invoked and the menu is unposted.
#
# Arguments:
# w - The name of the menu widget.
# char - The character to look for; case is
# ignored. If the string is empty then
# nothing happens.
sub TraverseWithinMenu
{
 my $w = shift;
 my $char = shift;
 return unless (defined $char);
 $char = "\L$char";
 my $last = $w->index("last");
 return if ($last eq "none");
 for ($i = 0;$i <= $last;$i += 1)
  {
   my $label = eval {local $SIG{__DIE__};  $w->entrycget($i,"-label") };
   next unless defined($label);
   my $ul = $w->entrycget($i,"-underline");
   if (defined $ul && $ul >= 0)
    {
     $label = substr("\L$label",$ul,1);
     if (defined($label) && $label eq $char)
      {
       if ($w->type($i) eq 'cascade')
        {
         $w->postcascade($i);
         $w->activate($i);
         my $m2 = $w->entrycget($i,'-menu');
         $m2->FirstEntry if (defined $m2);
        }
       else
        {
         $w->Unpost();  
         $w->invoke($i);
        }
       return;
      }
    }
  }
}
# FirstEntry --
# Given a menu, this procedure finds the first entry that isn't
# disabled or a tear-off or separator, and activates that entry.
# However, if there is already an active entry in the menu (e.g.,
# because of a previous call to tkPostOverPoint) then the active
# entry isn't changed. This procedure also sets the input focus
# to the menu.
#
# Arguments:
# menu - Name of the menu window (possibly empty).
sub FirstEntry
{
 my $menu = shift;
 return if (!defined($menu) || $menu eq "" || !ref($menu));
 $menu->Enter;
 return if ($menu->index("active") ne "none");
 $last = $menu->index("last");
 return if ($last eq 'none');
 for ($i = 0;$i <= $last;$i += 1)
  {
   my $state = eval {local $SIG{__DIE__};  $menu->entrycget($i,"-state") };
   if (defined $state && $state ne "disabled" && !$menu->typeIS($i,"tearoff"))
    {
     $menu->activate($i);
     return;
    }
  }
}

# FindName --
# Given a menu and a text string, return the index of the menu entry
# that displays the string as its label. If there is no such entry,
# return an empty string. This procedure is tricky because some names
# like "active" have a special meaning in menu commands, so we can't
# always use the "index" widget command.
#
# Arguments:
# menu - Name of the menu widget.
# s - String to look for.
sub FindName
{
 my $menu = shift;
 my $s = shift;
 my $i = undef;
 if ($s !~ /^active$|^last$|^none$|^[0-9]|^@/)
  {
   $i = eval {local $SIG{__DIE__};  $menu->index($s) };
   return $i;
  }
 my $last = $menu->index("last");
 return if ($last eq 'none');
 for ($i = 0;$i <= $last;$i += 1)
  {
   my $label = eval {local $SIG{__DIE__};  $menu->entrycget($i,"-label") };
   return $i if (defined $label && $label eq $s);
  }
 return undef;
}
# PostOverPoint --
# This procedure posts a given menu such that a given entry in the
# menu is centered over a given point in the root window. It also
# activates the given entry.
#
# Arguments:
# menu - Menu to post.
# x, y - Root coordinates of point.
# entry - Index of entry within menu to center over (x,y).
# If omitted or specified as {}, then the menu's
# upper-left corner goes at (x,y).
sub PostOverPoint
{
 my $menu = shift;
 my $x = shift;
 my $y = shift;
 my $entry = shift;
 if (defined $entry)
  {
   if ($entry == $menu->index("last"))
    {
     $y -= ($menu->yposition($entry)+$menu->height)/2;
    }
   else
    {
     $y -= ($menu->yposition($entry)+$menu->yposition($entry+1))/2;
    }
   $x -= $menu->reqwidth/2;
  }
 $menu->post($x,$y);
 if (defined($entry) && $menu->entrycget($entry,"-state") ne "disabled")
  {
   $menu->activate($entry)
  }
}
# tk_popup --
# This procedure pops up a menu and sets things up for traversing
# the menu and its submenus.
#
# Arguments:
# menu - Name of the menu to be popped up.
# x, y - Root coordinates at which to pop up the
# menu.
# entry - Index of a menu entry to center over (x,y).
# If omitted or specified as {}, then menu's
# upper-left corner goes at (x,y).
sub Post
{
 my $menu = shift;
 return unless (defined $menu);
 my $x = shift;
 my $y = shift;
 my $entry = shift;
 Unpost(undef) if (defined($Tk::popup) || defined($Tk::postedMb));
 $menu->PostOverPoint($x,$y,$entry);
 $menu->grabGlobal;
 $Tk::popup = $menu;
 $Tk::focus = $menu->focusCurrent;
 $menu->focus();
}

# Converted from tearoff.tcl --
#
# This file contains procedures that implement tear-off menus.
#
# @(#) tearoff.tcl 1.3 94/12/17 16:05:25
#
# Copyright (c) 1994 The Regents of the University of California.
# Copyright (c) 1994 Sun Microsystems, Inc.
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# tkTearoffMenu --
# Given the name of a menu, this procedure creates a torn-off menu
# that is identical to the given menu (including nested submenus).
# The new torn-off menu exists as a toplevel window managed by the
# window manager. The return value is the name of the new menu.
#
# Arguments:
# w - The menu to be torn-off (duplicated).
sub TearOffMenu
{
 my $w = shift;
 # Find a unique name to use for the torn-off menu. Find the first
 # ancestor of w that is a toplevel but not a menu, and use this as
 # the parent of the new menu. This guarantees that the torn off
 # menu will be on the same screen as the original menu. By making
 # it a child of the ancestor, rather than a child of the menu, it
 # can continue to live even if the menu is deleted; it will go
 # away when the toplevel goes away.
 my $parent = $w->parent;
 while ($parent->toplevel != $parent || $parent->IsMenu)
  {
   $parent = $parent->parent;
  }
 my $menu = $w->MenuDup($parent);
 # $menu->overrideredirect(0);
 $menu->configure(-transient => 0);
 $menu->transient($parent);
 # Pick a title for the new menu by looking at the parent of the
 # original: if the parent is a menu, then use the text of the active
 # entry. If it's a menubutton then use its text.
 $parent = $w->parent;
 if ($parent->IsMenubutton)
  {
   $menu->title($parent->cget("-text"))
  }
 elsif ($parent->IsMenu)
  {
   $menu->title($parent->entrycget("active","-label"))
  }
 $menu->configure("-tearoff",0);
 $menu->post($w->x,$w->y);
 # Set tkPriv(focus) on entry: otherwise the focus will get lost
 # after keyboard invocation of a sub-menu (it will stay on the
 # submenu).
 $menu->bind("<Enter>",EnterFocus);
 $menu->Callback('-tearoffcommand');
}

# tkMenuDup --
# Given a menu (hierarchy), create a duplicate menu (hierarchy)
# in a given window.
#
# Arguments:
# src - Source window. Must be a menu. It and its
# menu descendants will be duplicated at dst.
# dst - Name to use for topmost menu in duplicate
# hierarchy.
sub MenuDup
{
 my $src    = shift;
 my $parent = shift;
 my @args   = ();
 my $option;
 foreach $option ($src->configure())
  {
   next if (@$option == 2);
   push(@args,$$option[0],$$option[4]);
  }
 my $dst = $parent->Menu(@args);
 my $last = $src->index("last");
 return if ($last eq 'none');
 my $i;
 for ($i = $src->cget("-tearoff");$i <= $last;$i += 1)
  {
   my $type = $src->type($i);
   if (defined $type)
    {
     @args = ();
     foreach $option ($src->entryconfigure($i))
      {
       next if (@$option == 2);
       push(@args,$$option[0],$$option[4]) if (defined $$option[4]);
      }
     $dst->add($type,@args);
     if ($type eq "cascade")
      {
       my $srcm = $src->entrycget($i,"-menu");
       if (defined $srcm)
        {
         $dst->entryconfigure($i,"-menu",$srcm->MenuDup($dst));
        }
      }
     elsif ($type eq "checkbutton" || $type eq "radiobutton")
      {
       $dst->entryconfigure($i,"-variable",$src->entrycget($i,"-variable"));
      }
    }
  }
 return $dst;
}

# Some convenience methods 

sub separator   { require Tk::Menu::Item; shift->Separator(@_);   }
sub command     { require Tk::Menu::Item; shift->Command(@_);     }
sub cascade     { require Tk::Menu::Item; shift->Cascade(@_);     }
sub checkbutton { require Tk::Menu::Item; shift->Checkbutton(@_); }
sub radiobutton { require Tk::Menu::Item; shift->Radiobutton(@_); }

1; 
