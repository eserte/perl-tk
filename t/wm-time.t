#!/usr/bin/perl -w
# -*- perl -*-


use strict;
use Tk;
use Test::More;
# Win32 gets one <visibility> event on toplevel and one on content (as expected)
# UNIX/X is more complex, as windows overlap (deliberately)
our $tests = 6;
our $expect = 0;
plan tests => $tests;

my $event = '<Map>';
my $why;
my $start;

sub begin
{
 $start = Tk::timeofday();
 $why = shift;
 $expect = shift;
 print "# Start $why $expect\n";
}

my $mw = new MainWindow;
my $l = $mw->Label(-text => 'Content')->pack;
#$l->bind($event,[\&mapped,"update"]);
$mw->bind($event,[\&mapped,"update"]);
$mw->geometry("+0+0");
begin('update',2);
$mw->update;

my $t = $mw->Toplevel(-width => 100, -height => 100);
$t->geometry("-0+0");
my $l2 = $t->Label(-text => 'Content')->pack;
$t->bind($event,[\&mapped,"Popup"]);
#$l2->bind($event,[\&mapped,"Popup"]);
begin('Popup',2);
$t->Popup(-popover => $mw);
$t->update;
begin('withdraw',0);
$t->withdraw;
begin('Popup Again',2);
$t->Popup(-popover => $mw);

$mw->after(1000, sub { begin('destroy',0); $mw->destroy });

MainLoop;


sub mapped
{
 my ($w) = @_;
 my $now = Tk::timeofday();
 my $delay = $now - $start;
 printf "# %s $why %.3g $expect\n",$w->PathName,$delay;
 if ($expect-- > 0)
  {
   ok($delay < 0.5,$why);
  }
}





