#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: $
# Author: Slaven Rezic
#

use strict;

use Tk;
use Tk::Config ();

BEGIN {
    if (!eval q{
	use Test::More;
	1;
    }) {
	print "1..0 # skip: no Test::More module\n";
	exit;
    }
}

plan tests => 1;

my $wm_name     = "<unknown>";
my $wm_version  = "<unknown>";

my $mw = MainWindow->new;
$mw->withdraw;

my @diag = ("",
	    "Tk platform:    $Tk::platform",
	   );

SKIP: {
    skip("window manager check only on X11", 1)
	if $Tk::platform ne "unix";

    my($type,$windowid) = eval { $mw->property('get', '_NET_SUPPORTING_WM_CHECK', 'root') };
    if (defined $windowid) {
	($wm_name) = eval { $mw->property('get', '_NET_WM_NAME', $windowid) };
	if (!$wm_name) {
	    if (eval { $mw->property('get', '_WINDOWMAKER_NOTICEBOARD', $windowid); 1 }
		|| eval { $mw->property('get', '_WINDOWMAKER_ICON_TILE', $windowid); 1 }) {
		$wm_name = "WindowMaker";
	    } else {
		$wm_name = "<unknown> (property _NET_SUPPORTING_WM_CHECK exists, but getting _NET_WM_NAME fails)";
	    }
	} else {
	    if ($wm_name eq 'Metacity') {
		($wm_version) = eval { $mw->property('get', '_METACITY_VERSION', $windowid) };
	    } else {
		# just guess the VERSION property
		my($maybe_wm_version) = eval { $mw->property('get', '_'.$wm_name.'_VERSION', $windowid) };
		if ($maybe_wm_version) {
		    $wm_version = $maybe_wm_version;
		}
	    }
	}
    }

    push @diag, ("window manager: $wm_name",
		 "       version: $wm_version",
		);

    pass("window manager check done");
}

my $Xft = $Tk::Config::xlib =~ /-lXft\b/ ? "yes" : "no";
push @diag, ("XFT:            $Xft");

diag join("\n", @diag);

__END__
