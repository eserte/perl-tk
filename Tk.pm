#
# Copyright (c) 1992-1994 The Regents of the University of California.
# Copyright (c) 1994 Sun Microsystems, Inc.
# Copyright (c) 1995-2003 Nick Ing-Simmons. All rights reserved.
# This program is free software; you can redistribute it and/or

# modify it under the same terms as Perl itself, subject
# to additional disclaimer in Tk/license.terms due to partial
# derivation from Tk8.0 sources.
#
package Tk;
require 5.00404;
use     Tk::Event ();
use     AutoLoader qw(AUTOLOAD);
use     DynaLoader;
use base qw(Exporter DynaLoader);

*fileevent = \&Tk::Event::IO::fileevent;

BEGIN {
 if($^O eq 'cygwin')
  {
   require Tk::Config;
   $Tk::platform = $Tk::Config::win_arch;
   $Tk::platform = 'unix' if $Tk::platform eq 'x';
  }
 else
  {
   $Tk::platform = ($^O eq 'MSWin32') ? $^O : 'unix';
  }
};

$Tk::tearoff = 1 if ($Tk::platform eq 'unix');

@EXPORT    = qw(Exists Ev exit MainLoop DoOneEvent tkinit);
@EXPORT_OK = qw(NoOp after *widget *event lsearch catch $XS_VERSION
                DONT_WAIT WINDOW_EVENTS  FILE_EVENTS TIMER_EVENTS
                IDLE_EVENTS ALL_EVENTS
                NORMAL_BG ACTIVE_BG SELECT_BG
                SELECT_FG TROUGH INDICATOR DISABLED BLACK WHITE);
%EXPORT_TAGS = (eventtypes => [qw(DONT_WAIT WINDOW_EVENTS  FILE_EVENTS
                                  TIMER_EVENTS IDLE_EVENTS ALL_EVENTS)],
                variables  => [qw(*widget *event)],
                colors     => [qw(NORMAL_BG ACTIVE_BG SELECT_BG SELECT_FG
                                  TROUGH INDICATOR DISABLED BLACK WHITE)],
               );

use strict;

use Carp;

# $tk_version and $tk_patchLevel are reset by pTk when a mainwindow
# is created, $VERSION is checked by bootstrap
$Tk::version     = '8.0';
$Tk::patchLevel  = '8.0';
$Tk::VERSION     = '800.025';
$Tk::XS_VERSION  = $Tk::VERSION;
$Tk::strictMotif = 0;

{($Tk::library) = __FILE__ =~ /^(.*)\.pm$/;}
$Tk::library = Tk->findINC('.') unless (defined($Tk::library) && -d $Tk::library);

$Tk::widget  = undef;
$Tk::event   = undef;

use vars qw($inMainLoop);

bootstrap Tk;

my $boot_time = timeofday();

# This is a workround for Solaris X11 locale handling
Preload(DynaLoader::dl_findfile('-L/usr/openwin/lib','-lX11'))
  if (NeedPreload() && -d '/usr/openwin/lib');

use Tk::Submethods ('option'    =>  [qw(add get clear readfile)],
                    'clipboard' =>  [qw(clear append)]
                   );

sub _backTrace
{
 my $w = shift;
 my $i = 1;
 my ($pack,$file,$line,$sub) = caller($i++);
 while (1)
  {
   my $loc = "at $file line $line";
   ($pack,$file,$line,$sub) = caller($i++);
   last unless defined($sub);
   return 1 if $sub eq '(eval)';
   $w->AddErrorInfo("$sub $loc");
  }
 return 0;
}

sub BackTrace
{
 my $w = shift;
 return unless (@_ || $@);
 my $mess = (@_) ? shift : "$@";
 die "$mess\n" if $w->_backTrace;
 # if we get here we are not in an eval so report now
 $w->Fail($mess);
 $w->idletasks;
 die "$mess\n";
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
 # Note that if a __DIE__ handler returns it re-dies up the chain.
 return unless defined $w;
 return if $w->_backTrace;
 # Not in an eval - should not happen
}

sub XEvent::xy { shift->Info('xy') }

sub XEvent::AUTOLOAD
{
 my ($meth) = $XEvent::AUTOLOAD =~ /(\w)$/;
 no strict 'refs';
 *{$XEvent::AUTOLOAD} = sub { shift->Info($meth) };
 goto &$XEvent::AUTOLOAD;
}

sub NoOp  { }

sub Ev
{
 if (@_ == 1)
  {
   my $arg = $_[0];
   return bless (((ref $arg) ? $arg : \$arg), 'Tk::Ev');
  }
 else
  {
   return bless [@_],'Tk::Ev';
  }
}

sub InitClass
{
 my ($package,$parent) = @_;
 croak "Unexpected type of parent $parent" unless(ref $parent);
 croak "$parent is not a widget" unless($parent->IsWidget);
 my $mw = $parent->MainWindow;
 my $hash = $mw->TkHash('_ClassInit_');
 unless (exists $hash->{$package})
  {
   $package->Install($mw);
   $hash->{$package} = $package->ClassInit($mw);
  }
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
 selection('own','-displayof',@_);
}

sub SelectionClear
{
 selection('clear','-displayof',@_);
}

sub SelectionExists
{
 selection('exists','-displayof',@_);
}

sub SelectionHandle
{my $widget = shift;
 my $command = pop;
 selection('handle',@_,$widget,$command);
}

sub SplitString
{
 local $_ = shift;
 my (@arr, $tmp);
 while (/\{([^{}]*)\}|((?:[^\s\\]|\\.)+)/gs) {
   if (defined $1) { push @arr, $1 }
   else { $tmp = $2 ; $tmp =~ s/\\([\s\\])/$1/g; push @arr, $tmp }
 }
 # carp '('.join(',',@arr).")";
 return @arr;
}

sub Methods
{
 my ($package) = caller;
 no strict 'refs';
 foreach my $meth (@_)
  {
   my $name = $meth;
   *{$package."::$meth"} = sub { shift->WidgetMethod($name,@_) };
  }
}


sub MessageBox {
    my ($kind,%args) = @_;
    require Tk::Dialog;
    my $parent = delete $args{'-parent'};
    my $args = \%args;

    $args->{-bitmap} = delete $args->{-icon} if defined $args->{-icon};
    $args->{-text} = delete $args->{-message} if defined $args->{-message};
    $args->{-type} = 'OK' unless defined $args->{-type};

    my $type;
    if (defined($type = delete $args->{-type})) {
	delete $args->{-type};
	my @buttons = grep($_,map(ucfirst($_),
                      split(/(abort|retry|ignore|yes|no|cancel|ok)/,
                            lc($type))));
	$args->{-buttons} = [@buttons];
	$args->{-default_button} = ucfirst(delete $args->{-default}) if
	    defined $args->{-default};
	if (not defined $args->{-default_button} and scalar(@buttons) == 1) {
	   $args->{-default_button} = $buttons[0];
	}
        my $md = $parent->Dialog(%$args);
        my $an = $md->Show;
        $md->destroy;
        return $an;
    }
} # end messageBox

sub messageBox
{
 my ($widget,%args) = @_;
 # remove in a later version:
 if (exists $args{'-text'})
  {
   warn "The -text option is deprecated. Please use -message instead";
   if (!exists $args{'-message'})
    {
     $args{'-message'} = delete $args{'-text'};
    }
  }
 $args{'-type'}    = (exists $args{'-type'})    ? lc($args{'-type'}) : 'ok';
 $args{'-default'} = lc($args{'-default'}) if (exists $args{'-default'});
 ucfirst tk_messageBox(-parent => $widget, %args);
}

sub getOpenFile
{
 tk_getOpenFile(-parent => shift,@_);
}

sub getSaveFile
{
 tk_getSaveFile(-parent => shift,@_);
}

sub chooseColor
{
 tk_chooseColor(-parent => shift,@_);
}

sub DialogWrapper
{
 my ($method,$kind,%args) = @_;
 my $created = 0;
 my $w = delete $args{'-parent'};
 if (defined $w)
  {
   $args{'-popover'} = $w;
  }
 else
  {
   $w = MainWindow->new;
   $w->withdraw;
   $created = 1;
  }
 my $mw = $w->MainWindow;
 my $fs = $mw->{$kind};
 unless (defined $fs)
  {
   $mw->{$kind} = $fs = $mw->$method(%args);
  }
 else
  {
   $fs->configure(%args);
  }
 my $val = $fs->Show;
 $w->destroy if $created;
 return $val;
}

sub ColorDialog
{
 require Tk::ColorEditor;
 DialogWrapper('ColorDialog',@_);
}

sub FDialog
{
 require Tk::FBox;
 my $cmd = shift;
 if ($cmd =~ /Save/)
  {
   push @_, -type => 'save';
  }
 DialogWrapper('FBox', $cmd, @_);
}

*MotifFDialog = \&FDialog;

sub MainLoop
{
 unless ($inMainLoop)
  {
   local $inMainLoop = 1;
   while (Tk::MainWindow->Count)
    {
     DoOneEvent(0);
    }
  }
}

sub tkinit { return MainWindow->new(@_) }

# a wrapper on eval which turns off user $SIG{__DIE__}
sub catch (&)
{
 my $sub = shift;
 eval {local $SIG{'__DIE__'}; &$sub };
}

my $Home;

sub TranslateFileName
{
 local $_ = shift;
 unless (defined $Home)
  {
   $Home = $ENV{'HOME'} || (defined $ENV{'HOMEDRIVE'} && defined $ENV{'HOMEPATH'} ? $ENV{'HOMEDRIVE'}.$ENV{'HOMEPATH'} : "");
   $Home =~ s#\\#/#g;
   $Home .= '/' unless $Home =~ m#/$#;
  }
 s#~/#$Home#g;
 # warn $_;
 return $_;
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

sub idletasks
{
 shift->update('idletasks');
}


1;

__END__

sub Error
{my $w = shift;
 my $error = shift;
 if (Exists($w))
  {
   my $grab = $w->grab('current');
   $grab->Unbusy if (defined $grab);
  }
 chomp($error);
 warn "Tk::Error: $error\n " . join("\n ",@_)."\n";
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
     $cur->tabFocus;
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
     $cur->tabFocus;
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
   return $w->viewable if ($value eq '1');
   $value = $w->$value();
   return $value if (defined $value);
  }
 if (!$w->viewable)
  {
   return 0;
  }
 catch { $value = $w->cget('-state') } ;
 if (!$@ && defined($value) && $value eq 'disabled')
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
 $w->Tk::focus() if ($d eq 'NotifyAncestor' ||  $d eq 'NotifyNonlinear' ||  $d eq 'NotifyInferior');
}

sub tabFocus
{
 shift->Tk::focus;
}

sub focusFollowsMouse
{
 my $widget = shift;
 $widget->bind('all','<Enter>','EnterFocus');
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
 return unless(defined $char && $char ne '');
 $w = $w->toplevel->FindMenu($char);
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
 $w = $w->toplevel->FindMenu('');
}

# These wrappers don't use method syntax so need to live
# in same package as raw Tk routines are newXS'ed into.

sub Selection
{my $widget = shift;
 my $cmd    = shift;
 croak 'Use SelectionOwn/SelectionOwner' if ($cmd eq 'own');
 croak "Use Selection\u$cmd()";
}

# If we have sub Clipboard in Tk then use base qw(Tk::Clipboard ....)
# calls it when it does its eval "require $base"
#sub Clipboard
#{my $w = shift;
# my $cmd    = shift;
# croak "Use clipboard\u$cmd()";
#}

sub Receive
{
 my $w = shift;
 warn 'Receive(' . join(',',@_) .')';
 die 'Tk rejects send(' . join(',',@_) .")\n";
}

sub break
{
 die "_TK_BREAK_\n";
}

sub updateWidgets
{
 my ($w) = @_;
 while ($w->DoOneEvent(DONT_WAIT|IDLE_EVENTS|WINDOW_EVENTS))
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




