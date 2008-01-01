#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: $
# Author: Slaven Rezic
#

use strict;

use Tk;
use Config qw(%Config);

BEGIN {
    if (!eval q{
	use Test::More;
	1;
    }) {
	print "1..0 # skip: no Test::More module\n";
	exit;
    }
}

BEGIN {
    if (!defined $Config{sig_name}) {
	print "1..0 # skip: No signals on this system?\n";
    }
    if ($Config{sig_name} !~ m{\bUSR2\b}) {
	print "1..0 # skip: signal USR2 is not available on this system\n";
    }
}

plan tests => 1;

my $caught_USR2 = 0;
$SIG{USR2} = sub { $caught_USR2++ };

my $ppid = $$;
if (fork == 0) {
    select undef,undef,undef,0.2;
    kill USR2 => $ppid;
    select undef,undef,undef,0.05;
    kill USR2 => $ppid;
    CORE::exit;
}

my $mw = tkinit;
$mw->geometry("+0+0");
$mw->Label(-text => "Waiting for USR2 signals...")->pack;
$mw->idletasks;

$mw->after(400, sub { $mw->destroy });

MainLoop;

is($caught_USR2, 2, "Caught USR2 signal exactly two times");

__END__
