#
# Copyright (c) 1992-1994 The Regents of the University of California.
# Copyright (c) 1994 Sun Microsystems, Inc.
# Copyright (c) 1995, 1996 Nick Ing-Simmons. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself, subject 
# to additional disclaimer in Tk/license.terms due to partial
# derivation from Tk4.0 sources.
#
package Tk;
require 5.002;
use     AutoLoader;
use     DynaLoader;
require Exporter;

@Tk::ISA  = qw(Exporter DynaLoader);


@EXPORT    = qw(Exists Ev after exit MainLoop DoOneEvent tkinit);
@EXPORT_OK = qw(NoOp *widget *event lsearch catch);

use vars qw($widget $event $library $version $patchlevel $VERSION $strictMotif);

use strict;
use Carp;

# $version and $patchLevel are reset by pTk when a mainwindow
# is created, $VERSION is checked by bootstrap
$Tk::version     = "4.0";
$Tk::patchLevel  = "4.0p3";
$Tk::VERSION     = '400.201';
$Tk::strictMotif = 0;
                                   
{($Tk::library) = __FILE__ =~ /^(.*)\.pm$/;}
$Tk::library = Tk->findINC('.') unless (-d $Tk::library);

$Tk::widget  = undef;
$Tk::event   = undef;

bootstrap Tk $Tk::VERSION;

my $boot_time = timeofday();

# This is a workround for Solaris X11 locale handling 
Preload(DynaLoader::dl_findfile('-L/usr/openwin/lib','-lX11')) if (&NeedPreload && -d '/usr/openwin/lib');

# Supress used once warnings on function table pointers 
# How can we do this in the C code?
use vars qw($TkVtab $TkintVtab $LangVtab $TkglueVtab $XlibVtab);  

use Tk::Submethods ('option'    =>  [qw(add get clear readfile)],
                    'clipboard' =>  [qw(clear append)]
                   );

sub BackTrace
{
 my $w = shift;
 return unless (@_ || $@);
 my $mess = (@_) ? shift : "$@";
 my $i = 0;  
 my ($pack,$file,$line,$sub) = caller($i++);
 while (1)   
  {          
   my $loc = "at $file line $line";
   ($pack,$file,$line,$sub) = caller($i++);
   last if (!defined($sub) || $sub eq '(eval)');
   $w->AddErrorInfo("$sub $loc");
  }          
 die "$mess\n";
}

sub NoOp  { }

sub Ev
{
 my @args = @_;
 my $obj;
 if (@args == 1)
  {
   my $arg = pop(@args);
   $obj = (ref $arg) ? $arg : \$arg;
  }
 else 
  {
   $obj = \@args;
  }
 return bless $obj,"Tk::Ev";
}

require Tk::Widget;
require Tk::Image;
require Tk::MainWindow;

sub Exists
{my $w = shift;
 return defined($w) && ref($w) && $w->IsWidget && $w->exists;
}

sub Time_So_Far
{
 return timeofday() - $boot_time;
} 

# Selection* are not autoloaded as names are too long.

sub SelectionOwn
{my $widget = shift;
 selection('own',(@_,$widget));
}

sub SelectionOwner
{
 selection('own',"-displayof",@_);
}

sub SelectionClear
{
 selection('clear',"-displayof",@_);
}

sub SelectionExists
{
 selection('exists',"-displayof",@_);
}

sub SelectionHandle
{my $widget = shift;
 my $command = pop;
 selection('handle',@_,$widget,$command);
}

#
# This is a $SIG{__DIE__} handler which does not change the $@
# string in the way 'croak' does, but rather add to Tk's ErrorInfo.
# It stops at 1st enclosing eval on assumption that the eval
# is part of Tk call process and will add its own context to ErrorInfo
# and then pass on the error.
# 
sub __DIE__
{
 my $mess = shift;
 my $w = $Tk::widget;
 if (defined $w)
  {
   my $i = 0;  
   my ($pack,$file,$line,$sub) = caller($i++);
   while (1)   
    {          
     my $loc = "at $file line $line";
     ($pack,$file,$line,$sub) = caller($i++);
     last if (!defined($sub) || $sub eq '(eval)');
     $w->AddErrorInfo("$sub $loc");
    }          
  }
}

1;

__END__
# provide an exit() to be exported if exit occurs 
# before a MainWindow->new()
sub exit { CORE::exit(@_);}

sub Error
{my $w = shift;
 my $error = shift;
 if (Exists($w))
  {
   my $grab = $w->grab('current');  
   $grab->Unbusy if (defined $grab);
  }
 chomp($error);
 warn "Tk::Error: $error\n " . join("\n ",@_);
}

sub tkinit
{
 return MainWindow->new(@_);
}

sub CancelRepeat
{
 my $w = shift->MainWindow;
 my $id = delete $w->{_afterId_};
 $w->after('cancel',$id) if (defined $id);
}

sub RepeatId
{
 my ($w,$id) = @_;
 $w = $w->MainWindow;
 $w->CancelRepeat;
 $w->{_afterId_} = $id;
}



#----------------------------------------------------------------------------
# focus.tcl --
#
# This file defines several procedures for managing the input
# focus.
#
# @(#) focus.tcl 1.6 94/12/19 17:06:46
#
# Copyright (c) 1994 Sun Microsystems, Inc.
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.

sub FocusChildren { shift->children }

#
# focusNext --
# This procedure is invoked to move the input focus to the next window
# after a given one. "Next" is defined in terms of the window
# stacking order, with all the windows underneath a given top-level
# (no matter how deeply nested in the hierarchy) considered except
# for frames and toplevels.
#
# Arguments:
# w - Name of a window: the procedure will set the focus
# to the next window after this one in the traversal
# order.
sub focusNext
{
 my $w = shift;
 my $cur = $w;
 while (1)
  {
   # Descend to just before the first child of the current widget.
   my $parent = $cur;
   my @children = $cur->FocusChildren();
   my $i = -1;
   # Look for the next sibling that isn't a top-level.
   while (1)
    {
     $i += 1;
     if ($i < @children)
      {
       $cur = $children[$i];
       next if ($cur->toplevel == $cur);
       last
      }
     # No more siblings, so go to the current widget's parent.
     # If it's a top-level, break out of the loop, otherwise
     # look for its next sibling.
     $cur = $parent;
     last if ($cur->toplevel() == $cur);
     $parent = $parent->parent();
     @children = $parent->FocusChildren();
     $i = lsearch(\@children,$cur);
    }
   if ($cur == $w || $cur->FocusOK)
    {
     $cur->Tk::focus;
     return;
    }
  }
}
# focusPrev --
# This procedure is invoked to move the input focus to the previous
# window before a given one. "Previous" is defined in terms of the
# window stacking order, with all the windows underneath a given
# top-level (no matter how deeply nested in the hierarchy) considered.
#
# Arguments:
# w - Name of a window: the procedure will set the focus
# to the previous window before this one in the traversal
# order.
sub focusPrev
{
 my $w = shift;
 my $cur = $w;
 my @children;
 my $i;
 my $parent;
 while (1)
  {
   # Collect information about the current window's position
   # among its siblings. Also, if the window is a top-level,
   # then reposition to just after the last child of the window.
   if ($cur->toplevel() == $cur)
    {
     $parent = $cur;
     @children = $cur->FocusChildren();
     $i = @children;
    }
   else
    {
     $parent = $cur->parent();
     @children = $parent->FocusChildren();
     $i = lsearch(\@children,$cur);
    }
   # Go to the previous sibling, then descend to its last descendant
   # (highest in stacking order. While doing this, ignore top-levels
   # and their descendants. When we run out of descendants, go up
   # one level to the parent.
   while ($i > 0)
    {
     $i--;
     $cur = $children[$i];
     next if ($cur->toplevel() == $cur);
     $parent = $cur;
     @children = $parent->FocusChildren();
     $i = @children;
    }
   $cur = $parent;
   if ($cur == $w || $cur->FocusOK)
    {
     $cur->Tk::focus;
     return;
    }
  }

}

sub FocusOK
{
 my $w = shift;
 my $value;
 catch { $value = $w->cget('-takefocus') };
 if (!$@ && defined($value))
  {
   return 0 if ($value eq '0');
   return 1 if ($value eq '1');
   $value = $w->$value();
   return $value if (defined $value);
  }
 if (!$w->viewable)
  {
   return 0;
  }
 catch { $value = $w->cget('-state') } ;
 if (!$@ && defined($value) && $value eq "disabled")
  {
   return 0;
  }
 $value = grep(/Key|Focus/,$w->Tk::bind(),$w->Tk::bind(ref($w)));
 return $value;
}


# focusFollowsMouse
#
# If this procedure is invoked, Tk will enter "focus-follows-mouse"
# mode, where the focus is always on whatever window contains the
# mouse. If this procedure isn't invoked, then the user typically
# has to click on a window to give it the focus.
#
# Arguments:
# None.

sub EnterFocus
{
 my $w  = shift;
 my $Ev = $w->XEvent;
 my $d  = $Ev->d;
 $w->Tk::focus() if ($d eq "NotifyAncestor" ||  $d eq "NotifyNonlinear" ||  $d eq "NotifyInferior");
}

sub focusFollowsMouse
{
 my $widget = shift;
 $widget->bind('all',"EnterFocus");
}

# tkTraverseToMenu --
# This procedure implements keyboard traversal of menus. Given an
# ASCII character "char", it looks for a menubutton with that character
# underlined. If one is found, it posts the menubutton's menu
#
# Arguments:
# w - Window in which the key was typed (selects
# a toplevel window).
# char - Character that selects a menu. The case
# is ignored. If an empty string, nothing
# happens.
sub TraverseToMenu
{
 my $w = shift;
 my $char = shift;
 return unless(defined $char && $char ne "");
 $w = $w->toplevel->FindMenu($char);
 $w->PostFirst() if (defined $w);
}
# tkFirstMenu --
# This procedure traverses to the first menubutton in the toplevel
# for a given window, and posts that menubutton's menu.
#
# Arguments:
# w - Name of a window. Selects which toplevel
# to search for menubuttons.
sub FirstMenu
{
 my $w = shift;
 $w = $w->toplevel->FindMenu("");
 $w->PostFirst() if (defined $w);
}

# These wrappers don't use method syntax so need to live
# in same package as raw Tk routines are newXS'ed into.

sub Selection
{my $widget = shift;
 my $cmd    = shift;
 croak "Use SelectionOwn/SelectionOwner" if ($cmd eq 'own');
 croak "Use Selection\u$cmd()";
}

sub Clipboard
{my $w = shift;
 my $cmd    = shift;
 croak "Use clipboard\u$cmd()";
}

sub Receive
{
 my $w = shift;
 warn "Receive(" . join(',',@_) .")";
 die "Tk rejects send(" . join(',',@_) .")\n";
}

sub break
{
 die "_TK_BREAK_\n";
}

sub idletasks
{
 shift->update('idletasks');
}

sub updateWidgets
{
 my ($w) = @_;
 while ($w->DoOneEvent(0x13))   # No wait, X events and idle events
  {
  }
 $w;
}

sub ImageNames
{
 image('names');
}

sub ImageTypes
{
 image('types');
}

sub interps
{
 my $w = shift;
 return $w->winfo('interps','-displayof');
}

sub findINC
{
 my $file = join('/',@_);
 my $dir;
 $file  =~ s,::,/,g;
 foreach $dir (@INC)
  {
   my $path;
   return $path if (-e ($path = "$dir/$file"));
  }
 return undef;
}

sub lsearch
{my $ar = shift;
 my $x  = shift;
 my $i;
 for ($i = 0; $i < scalar @$ar; $i++)
  {
   return $i if ($$ar[$i] eq $x);
  }
 return -1;
}

# a wrapper on eval which turns off user $SIG{__DIE__}
sub catch (&)
{
 my $sub = shift;
 eval {local $SIG{'__DIE__'}; &$sub };
}

