# Copyright (c) 1995-1998 Nick Ing-Simmons. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
package Tk::MainWindow;
@Tk::MainWindow::ISA = qw(Tk::Toplevel);
@MainWindow::ISA = 'Tk::MainWindow';

use AutoLoader;  

use strict;

use vars qw($VERSION);
$VERSION = '3.008'; # $Id: //depot/Tk8/Tk/MainWindow.pm#8$

use Tk::CmdLine;
require Tk;
require Tk::Toplevel;

use Carp;

$| = 1;


my $pid = $$;

my @Windows = ();

sub CreateArgs
{
 my ($class,$args) = @_;
 my $cmd = Tk::CmdLine::CreateArgs();
 my $key;
 foreach $key (keys %$cmd)
  {
   $args->{$key} = $cmd->{$key} unless exists $args->{$key};
  }
 my %result = $class->SUPER::CreateArgs(undef,$args);
 my $name = delete($args->{'-name'});
 $ENV{'DISPLAY'} = ':0' unless (exists $ENV{'DISPLAY'});
 $result{'-screen'} = $ENV{'DISPLAY'} unless exists $result{'-screen'};
 return (-name => "\l$name",%result);
}

sub new
{
 my $package = shift;
 if (@_ > 0 && $_[0] =~ /:\d+(\.\d+)?$/)
  {
   carp "Usage $package->new(-screen => '$_[0]' ...)" if $^W;
   unshift(@_,'-screen');
  }
 croak("Odd number of args"."$package->new(" . join(',',@_) .")") if @_ % 2;
 my %args = @_;

 my $top = eval { bless Create($package->CreateArgs(\%args)), $package };
 croak($@ . "$package->new(" . join(',',@_) .")") if ($@);
 $top->apply_command_line;
 $top->InitBindings;
 $top->InitObject(\%args);
 eval { $top->configure(%args) };
 croak "$@" if ($@);
 $top->SetBindtags;
 push(@Windows,$top);
 return $top;
}

sub InitBindings
{
 my $mw = shift;
 $mw->bind('all',"<Tab>","focusNext");
 $mw->bind('all',"<Shift-Tab>","focusPrev");  
 if ($Tk::platform eq 'unix')
  {
   $mw->eventAdd(qw[<<Cut>> <Control-Key-x> <Key-F20> <Meta-Key-w>]);
   $mw->eventAdd(qw[<<Copy>> <Control-Key-c> <Key-F16> <Control-Key-w>]);
   $mw->eventAdd(qw[<<Paste>> <Control-Key-v> <Key-F18> <Control-Key-y>]);
  }
 else
  {
   $mw->eventAdd(qw[<<Cut>> <Control-Key-x> <Shift-Key-Delete>]);
   $mw->eventAdd(qw[<<Copy>> <Control-Key-c> <Control-Key-Insert>]);
   $mw->eventAdd(qw[<<Paste>> <Control-Key-v> <Shift-Key-Insert>]);
  }

 # FIXME - Should these move to Menubutton ? 
 my $c = ($Tk::platform eq 'unix') ? 'all' : 'Tk::Menubutton';
 $mw->bind($c,"<Alt-KeyPress>",['TraverseToMenu',Tk::Ev('A')]);
 $mw->bind($c,"<F10>",'FirstMenu');
}


sub Existing
{
 grep( Tk::Exists($_), @Windows);  
}


END
{
 if ($pid == $$)
  {
   my $top;
   while ($top = pop(@Windows))
    {
     if ($top->IsWidget)
      {
       # Tk data structuctures are still in place
       # this can occur if non-callback perl code did a 'die'.
       # It will also handle some cases of non-Tk 'exit' being called
       # Destroy this mainwindow and hence is descendants ...
       $top->destroy; 
      }
    }
  }
}

sub CmdLine { return shift }

sub WMSaveYourself
{
 my $mw  = shift;
 my @args = @{$mw->command};
 warn "preWMSaveYourself:".join(' ',@args)."\n";
 @args = ($0) unless (@args);
 my $i = 1;
 while ($i < @args)
  {
   if ($args[$i] eq '-iconic')
    {
     splice(@args,$i,1); 
    }
   elsif ($args[$i] =~ /^-(geometry|iconposition)$/)
    {
     splice(@args,$i,2); 
    }
  }

 my @ip = $mw->wm('iconposition');
 print "ip ",join(',',@ip),"\n";
 my $icon = $mw->iconwindow;
 if (defined($icon))
  {
   @ip = $icon->geometry =~ /\d+x\d+([+-]\d+)([+-]\d+)/;
  }
 splice(@args,1,0,'-iconposition' => join(',',@ip)) if (@ip == 2);

 splice(@args,1,0,'-iconic') if ($mw->state() eq 'iconic');

 splice(@args,1,0,'-geometry' => $mw->geometry);
 warn "postWMSaveYourself:".join(' ',@args)."\n";
 $mw->command([@args]);
}


1;

__END__

=head1 NAME

Tk::MainWindow - Root widget of a widget tree

=head1 SYNOPSIS

    use Tk;

    my $mw = MainWindow->new( ... options ... );

    my $this = $mw->ThisWidget -> pack ;
    my $that = $mw->ThatWidget;
    ...

    MainLoop;


=head1 DESCRIPTION

B<Tk::MainWindow> is a special kind of B<Toplevel> widget. It's
the root of a widget tree. Therefore C<$mw-E<gt>Parent> returns
C<undef>.

Unlike the standard Tcl/Tk's wish, perl/Tk allows you to create
several MainWindows.  When the I<last> B<MainWindow> is destroyed
the Tk eventloop exits (the eventloop is entered with the call of
C<MainLoop>).

The default title of a MainWindow is the basename of the script
(actually the Class name used for options lookup, i.e. with basename
with inital caps) or 'Ptk' as the fallback value.  If more than one MainWindow is created
or several instances of the script are running at the same time the
string C<" #n"> is appended where the number C<n> is unset to get
a unique value.


=head1 METHODS

You can apply all methods that a L<Tk::Toplevel> accepts.

To access the B<MainWindow> one can use for all widget the method
C<$w->Mainwindow()> that returns a reference to the B<MainWindow>.
the widget belongs to (the MainWindow belongs to itself).


=head1 MISSING

Documentation is incomplete. Category: better than nothing.
Here are I<some> of missing items that should be explained is
more details:

=over 4

=item *

There no explanation about what resources are bound
to a MainWindow (e.g., ClassInit done per MainWindow)

=item *

Passing of command line options to override or augment
arguments of the C<new> method (see L<Tk::CmdLine>).

=back


=head1 SEE ALSO

Tk::Toplevel, Tk::CmdLine


=cut
