#!/usr/bin/perl -w
# -*- perl -*-

use strict;
use Tk;
use Test::More;
plan tests => 12;

my $event = '<Visibility>';
my $why;
my $start;

sub begin
{
 $start = Tk::timeofday();
 $why = shift;
}

my $mw = new MainWindow;
my $l = $mw->Label(-text => 'Content')->pack;
#$l->bind($event,[\&mapped,"update"]);
$mw->bind($event,[\&mapped,"update"]);
$mw->geometry("+0+0");
begin('update');
$mw->update;

my $t = $mw->Toplevel(-width => 100, -height => 100);
my $l2 = $t->Label(-text => 'Content')->pack;
$t->bind($event,[\&mapped,"Popup"]);
#$l2->bind($event,[\&mapped,"Popup"]);
begin('Popup');
$t->Popup(-popover => $mw);
$t->update;
begin('withdraw');
$t->withdraw;
begin('Popup Again');
$t->Popup(-popover => $mw);

$mw->after(1000, sub { begin('destroy'); $mw->destroy });

MainLoop;


sub mapped
{
 my ($w) = @_;
 my $now = Tk::timeofday();
 my $delay = $now - $start;
 printf "# %s $why %.3g\n",$w->PathName,$delay;
 ok($delay < 0.5,$why);
}





