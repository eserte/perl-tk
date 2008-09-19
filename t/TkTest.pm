# Copyright (C) 2003,2006,2007 Slaven Rezic. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package TkTest;

use strict;
use vars qw(@EXPORT @EXPORT_OK $eps $VERSION);
$VERSION = '4.006'; # was: sprintf '4.%03d', q$Revision: #3 $ =~ /\D(\d+)\s*$/;

use base qw(Exporter);
@EXPORT    = qw(is_float is_float_pair check_display_harness);
@EXPORT_OK = qw(catch_grabs wm_info);

use POSIX qw(DBL_EPSILON);
$eps = DBL_EPSILON;

sub check_display_harness () {
    # In case of cygwin, use'ing Tk before forking (which is done by
    # Test::Harness) may lead to "remap" errors, which are normally
    # solved by the rebase or rebaseall utilities.
    #
    # Here, I just skip the DISPLAY check on cygwin to not force users
    # to run rebase.
    #
    return if $^O eq 'cygwin' || $^O eq 'MSWin32';

    eval q{
           use blib;
           use Tk;
        };
    die "Strange: could not load Tk library: $@" if $@;

    if (defined $Tk::platform && $Tk::platform eq 'unix') {
	my $mw = eval { MainWindow->new() };
	if (!Tk::Exists($mw)) {
	    warn "Cannot create MainWindow (maybe no X11 server is running or DISPLAY is not set?)\n$@\n";
	    exit 0;
	}
	$mw->destroy;
    }
}

sub is_float ($$;$) {
    my($value, $expected, $testname) = @_;
    local $Test::Builder::Level = $Test::Builder::Level+1;
    my @value    = split /[\s,]+/, $value;
    my @expected = split /[\s,]+/, $expected;
    my $ok = 1;
    for my $i (0 .. $#value) {
	if ($expected[$i] =~ /^[\d+-]/) {
	    if (abs($value[$i]-$expected[$i]) > $eps) {
		$ok = 0;
		last;
	    }
	} else {
	    if ($value[$i] ne $expected[$i]) {
		$ok = 0;
		last;
	    }
	}
    }
    if ($ok) {
	Test::More::pass($testname);
    } else {
	Test::More::is($value, $expected, $testname); # will fail
    }
}

sub is_float_pair ($$;$) {
    my($values, $expected, $testname) = @_;
    local $Test::Builder::Level = $Test::Builder::Level+1;
    for my $def ([0, "first value"],
		 [1, "second value"],
		) {
	my($inx, $testname_add) = @$def;
	is_float($values->[$inx], $expected->[$inx], (defined $testname ? "$testname " : "") . "($testname_add)");
    }
}

sub catch_grabs (&;$) {
    my($code, $tests) = @_;
    $tests = 1 if !defined $tests;
    my $tests_before = Test::More->builder->current_test;
    eval {
	$code->();
    };
    if ($@ && $@ !~ m{^\Qgrab failed: another application has grab}) {
	die $@;
    }
    my $tests_after = Test::More->builder->current_test;
    if ($tests_after - $tests_before != $tests) {
	for (1 .. $tests - ($tests_after - $tests_before)) {
	    Test::More::pass("Ignore test because other application had grab");
	}
    }
}

sub wm_info ($) {
    my $mw = shift;

    return () if $Tk::platform ne "unix";

    my $wm_name     = "<unknown>";
    my $wm_version  = "<unknown>";

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
    } else {
	my($dtwm_integer) = eval { $mw->property('get', 'DTWM_IS_RUNNING', 'root') };
	if (defined $dtwm_integer) { # XXX really have to check this
                                     # integer, probably a Window id?
	    $wm_name = "dtwm";
	}
    }

    $wm_name =~ s{\0}{}g; # null byte at end seen in xfwm4 4.2.3.2

    (name    => $wm_name,
     version => $wm_version,
    );
}

1;

__END__
