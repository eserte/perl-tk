#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: $
# Author: Slaven Rezic
#

use strict;

use Tk;

BEGIN {
    if (!eval q{
	use Test::More;
	1;
    }) {
	print "1..0 # skip: no Test::More module\n";
	exit;
    }
}

BEGIN { plan tests => 1 }

my $mw = MainWindow->new;
$mw->withdraw;
$mw->geometry("+10+10");
my $icon = $mw->Photo(-format => 'gif',
		      -file => Tk->findINC('Xcamel.gif'));
$mw->iconimage($icon);
$mw->iconify;
$mw->idletasks;
ok(1);
$mw->after(1000,[destroy => $mw]);
MainLoop;

__END__


