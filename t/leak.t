#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: leak.t,v 1.3 2002/03/07 23:04:54 eserte Exp $
# Author: Slaven Rezic
#

# Some leak tests. You need Devel::Leak installed and a debugging perl.
# I usually use this arguments to perl's Configure:
#
#     -Doptimize='-g -DPERL_DEBUGGING_MSTATS' -Dusemymalloc='y'
#
# With the patches for tkGlue.c and pTkCallback.c (see the patches
# subdirectory), the problems here should get away.
#

use strict;
use Config;
use Tk;
use Tk::Button;
use Tk::Canvas;

BEGIN {
    if (!eval q{
	use Test;
	use Devel::Leak;
	die if $Config{optimize} !~ /-DPERL_DEBUGGING_MSTATS/;
	1;
    }) {
	print "# tests only work with installed Test and Devel::Leak modules\n";
	print "# also -DPERL_DEBUGGING_MSTATS have to be set\n";
	print "1..1\n";
	print "ok 1\n";
	exit;
    }
}

{
    # gather all todos marked with "TODO: number"
    my @todos;
    open(DATA, $0) or die $!;
    while(<DATA>) {
	push @todos, $1 if (/^\#\s+TODO:\s+(\d+)/);
    }
    close DATA;
    plan tests => 8, todo => [@todos];
}

my $mw = new MainWindow;
my $handle;
my($c1,$c2);

# Tests for leaking subroutine set

# first binding always creates some SVs
$mw->bind("<Motion>" => [sub { warn }]);

$c1 = Devel::Leak::NoteSV($handle);
for(1..100) {
    $mw->bind("<Motion>" => [sub { warn }]);
}
$c2 = Devel::Leak::NoteSV($handle);
ok($c1, $c2);

# TODO: 2
$c1 = Devel::Leak::NoteSV($handle);
for(1..100) {
    $mw->bind("<Motion>" => sub { warn });
}
$c2 = Devel::Leak::NoteSV($handle);
ok($c1, $c2);

# TODO: 3
$c1 = Devel::Leak::NoteSV($handle);
for(1..100) {
    $mw->bind("<Motion>" => \&test);
}
$c2 = Devel::Leak::NoteSV($handle);
ok($c1, $c2);

my $btn = $mw->Button(-command => sub { warn });
# TODO: 4
$c1 = Devel::Leak::NoteSV($handle);
for(1..100) {
    $btn->configure(-command => sub { warn });
}
$c2 = Devel::Leak::NoteSV($handle);
ok($c1, $c2);

# Tests for leaking Tk_GetUid (e.g. canvas items)

my $c = $mw->Canvas->pack;
$c->createLine(10,10,100,100, -tags => "a");

$c1 = Devel::Leak::NoteSV($handle);
for(1..100) {
    $c->createLine(10,10,100,100,-tags => "a");
    $c->delete("a");
}
$c2 = Devel::Leak::NoteSV($handle);
ok($c1, $c2);

# TODO: 6
$c1 = Devel::Leak::NoteSV($handle);
for(1..100) {
    my $id = $c->createLine(10,10,100,100);
    $c->delete($id);
}
$c2 = Devel::Leak::NoteSV($handle);
ok($c1, $c2);

# Tests for leaking widget destroys
my $btn2 = $mw->Button;
$btn2->destroy;

# TODO: 7
$c1 = Devel::Leak::NoteSV($handle);
for(1..100) {
    my $btn2 = $mw->Button;
    $btn2->destroy;
}
$c2 = Devel::Leak::NoteSV($handle);
ok($c1, $c2);

# Tests for leaking fileevent callbacks
$mw->fileevent(\*STDOUT, 'readable', sub { });
$mw->fileevent(\*STDOUT, 'readable','');

# TODO: 8
$c1 = Devel::Leak::NoteSV($handle);
$mw->fileevent(\*STDOUT, 'readable', sub { });
$mw->fileevent(\*STDOUT, 'readable','');
$c2 = Devel::Leak::CheckSV($handle);
ok($c1, $c2);

sub test { warn }

__END__
