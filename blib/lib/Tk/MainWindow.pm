# Copyright (c) 1995-1997 Nick Ing-Simmons. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
package Tk::MainWindow;
@Tk::MainWindow::ISA = qw(Tk::Toplevel);
@MainWindow::ISA = 'Tk::MainWindow';

use AutoLoader;  

use strict;

use vars qw($VERSION);
$VERSION = '2.011'; # $Id: //depot/Tk/Tk/MainWindow.pm#11$

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
 return ("\l$name",%result);
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
                                    
 $mw->bind('all',"<Alt-KeyPress>",['TraverseToMenu',Tk::Ev('A')]);
 $mw->bind('all',"<F10>",'FirstMenu');
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


