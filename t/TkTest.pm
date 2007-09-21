# Copyright (C) 2003,2006,2007 Slaven Rezic. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package TkTest;

use strict;
use vars qw(@EXPORT @EXPORT_OK $eps $VERSION);
$VERSION = '4.004'; # was: sprintf '4.%03d', q$Revision: #3 $ =~ /\D(\d+)\s*$/;

use base qw(Exporter);
@EXPORT    = qw(is_float check_display_harness);
@EXPORT_OK = qw(catch_grabs);

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

1;

__END__
