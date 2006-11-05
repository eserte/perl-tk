#!/usr/bin/perl -w
# -*- perl -*-

# This file is a Tcl script to test out Tk's interactions with
# the window manager, including the "wm" command.  It is organized
# in the standard fashion for Tcl tests.
#
# Copyright (c) 1992-1994 The Regents of the University of California.
# Copyright (c) 1994-1997 Sun Microsystems, Inc.
# Copyright (c) 1998-1999 by Scriptics Corporation.
# All rights reserved.
#
# RCS: @(#) $Id$

# This file tests window manager interactions that work across
# platforms. Window manager tests that only work on a specific
# platform should be placed in unixWm.test or winWm.test.

#
# Translated by Slaven Rezic (2006-11, from CVS version 1.36)
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

plan tests => 48;

my $mw = MainWindow->new;
$mw->geometry("+10+10");

$mw->deiconify;
if (!$mw->ismapped) {
    $mw->waitVisibility;
}

my $t;

sub stdWindow () {
    $t->destroy if Tk::Exists($t);
    $t = $mw->Toplevel(qw(-width 100 -height 50));
    $t->geometry("+0+0");
    $t->update
}

sub deleteWindows () {
    eval { $_->destroy } for $mw->children;
}

# [raise] and [lower] may return before the window manager
# has completed the operation.  The raiseDelay procedure
# idles for a while to give the operation a chance to complete.
#

sub raiseDelay () {
    $mw->after(100);
    $mw->update;
}

deleteWindows;
stdWindow;

{
    my $b = $mw->Button(-text => "hello");
    eval { Tk::Wm::geometry($b) }; # one shouldn't do this anyway
    like($@, qr{window ".button" isn't a top-level window},
	 q{Tk_WmObjCmd procedure, miscellaneous errors});
    $b->destroy;
}

### wm aspect ###
{
    eval { $mw->aspect("_") };
    like($@, qr{\Qwrong # args: should be "wm aspect window ?minNumer minDenom maxNumer maxDenom?"\E},
	 "wm aspect usage");

    eval { $mw->aspect("_", "_", "_") };
    like($@, qr{\Qwrong # args: should be "wm aspect window ?minNumer minDenom maxNumer maxDenom?"\E});

    eval { $mw->aspect("_", "_", "_", "_", "_") };
    like($@, qr{\Qwrong # args: should be "wm aspect window ?minNumer minDenom maxNumer maxDenom?"\E});

    eval { $mw->aspect(qw(bad 14 15 16)) };
    like($@, qr{'bad' isn't numeric});

    eval { $mw->aspect(qw(13 foo 15 16)) };
    like($@, qr{'foo' isn't numeric});

    eval { $mw->aspect(qw(13 14 bar 16)) };
    like($@, qr{'bar' isn't numeric});

    eval { $mw->aspect(qw(13 14 15 baz)) };
    like($@, qr{'baz' isn't numeric});

    eval { $mw->aspect(qw(0 14 15 16)) };
    like($@, qr{\Qaspect number can't be <= 0});

    eval { $mw->aspect(qw(13 0 15 16)) };
    like($@, qr{\Qaspect number can't be <= 0});

    eval { $mw->aspect(qw(13 14 0 16)) };
    like($@, qr{\Qaspect number can't be <= 0});

    eval { $mw->aspect(qw(13 14 15 0)) };
    like($@, qr{\Qaspect number can't be <= 0});
}

{
    is_deeply([$mw->aspect], [], "setting and reading aspect values");
    $mw->aspect(qw(3 4 10 2));
    is_deeply([$mw->aspect], [qw(3 4 10 2)]);
    $mw->aspect(undef,undef,undef,undef);
    is_deeply([$mw->aspect],[]);
}

### wm attributes ###
{
    eval { $mw->attributes(-alpha => 1.0, '-disabled') };
    like($@, qr{\Qwrong # args: should be "wm attributes window ?-attribute ?value ...??});

 SKIP: {
	skip("works only on windows", 1)
	    if $Tk::platform ne 'MSWin32';
	eval { $mw->attributes('-to') };
	like($@, qr{\Qwrong # args: should be "wm attributes window ?-alpha ?double?? ?-disabled ?bool?? ?-fullscreen ?bool?? ?-toolwindow ?bool?? ?-topmost ?bool??"});
    }
    
 SKIP: {
	skip("works only on unix", 1)
	    if $Tk::platform ne 'unix';
	eval { $mw->attributes("_") };
	like($@, qr{\Qbad attribute "_": must be -alpha, -topmost, -zoomed, or -fullscreen},
	     "wm attributes usage");
    }

 SKIP: {
	skip("works only on aqua", 1)
	    if $Tk::platform ne 'aqua';
	die <<EOF;
not yet translated:
test wm-attributes-1.2.5 {usage} aqua {
    list [catch {wm attributes . _} err] \$err
} {1 {bad attribute "_": must be -alpha, -modified, -notify, or -titlepath}}
EOF
    }
}

{
    ### wm client ###
    is($t->client, undef, "wm client, setting and reading values");
    $t->client('Miffo');
    is($t->client, 'Miffo');
    $t->client(undef);
    is($t->client, undef);
}

SKIP: {
    skip("fullscreen tests only on windows", 1) # XXX correct no. of tests
	if $Tk::platform ne 'MSWin32';

    die <<'EOF';
TESTS NOT YET TRANSLATED!

test wm-attributes-1.3.0 {default -fullscreen value} {win} {
    deleteWindows
    toplevel .t
    wm attributes .t -fullscreen
} {0}

test wm-attributes-1.3.1 {change -fullscreen before map} {win} {
    deleteWindows
    toplevel .t
    wm attributes .t -fullscreen 1
    wm attributes .t -fullscreen
} {1}

test wm-attributes-1.3.2 {change -fullscreen before map} {win} {
    deleteWindows
    toplevel .t
    wm attributes .t -fullscreen 1
    update
    wm attributes .t -fullscreen
} {1}

test wm-attributes-1.3.3 {change -fullscreen after map} {win} {
    deleteWindows
    toplevel .t
    update
    wm attributes .t -fullscreen 1
    wm attributes .t -fullscreen
} {1}

test wm-attributes-1.3.4 {change -fullscreen after map} {win} {
    deleteWindows
    toplevel .t
    update
    set booleans [list]
    lappend booleans [wm attributes .t -fullscreen]
    wm attributes .t -fullscreen 1
    lappend booleans [wm attributes .t -fullscreen]
    # Query above should not clear fullscreen state
    lappend booleans [wm attributes .t -fullscreen]
    wm attributes .t -fullscreen 0
    lappend booleans [wm attributes .t -fullscreen]
    set booleans
} {0 1 1 0}

test wm-attributes-1.3.5 {change -fullscreen after map} {win} {
    deleteWindows
    toplevel .t
    set normal_geom "301x302+101+102"
    set fullscreen_geom "[winfo screenwidth .t]x[winfo screenheight .t]+0+0"
    wm geom .t $normal_geom
    update
    set results [list]
    lappend results [string equal [wm geom .t] $normal_geom]
    wm attributes .t -fullscreen 1
    lappend results [string equal [wm geom .t] $fullscreen_geom]
    wm attributes .t -fullscreen 0
    lappend results [string equal [wm geom .t] $normal_geom]
    set results
} {1 1 1}

test wm-attributes-1.3.6 {state change does not change -fullscreen} {win} {
    deleteWindows
    toplevel .t
    update
    wm attributes .t -fullscreen 1
    wm withdraw .t
    wm deiconify .t
    wm attributes .t -fullscreen
} {1}

test wm-attributes-1.3.7 {state change does not change -fullscreen} {win} {
    deleteWindows
    toplevel .t
    update
    wm attributes .t -fullscreen 1
    wm iconify .t
    wm deiconify .t
    wm attributes .t -fullscreen
} {1}

test wm-attributes-1.3.8 {override-redirect not compatible with fullscreen attribute} {win} {
    deleteWindows
    toplevel .t
    update
    wm overrideredirect .t 1
    list [catch {wm attributes .t -fullscreen 1} err] $err
} {1 {can't set fullscreen attribute for ".t": override-redirect flag is set}}

test wm-attributes-1.3.9 {max height too small} {win} {
    deleteWindows
    toplevel .t
    update
    wm maxsize .t 5000 450
    list [catch {wm attributes .t -fullscreen 1} err] $err
} {1 {can't set fullscreen attribute for ".t": max width/height is too small}}

test wm-attributes-1.3.10 {max height too small} {win} {
    deleteWindows
    toplevel .t
    update
    wm maxsize .t 450 5000
    list [catch {wm attributes .t -fullscreen 1} err] $err
} {1 {can't set fullscreen attribute for ".t": max width/height is too small}}

test wm-attributes-1.3.11 {another attribute, then -fullscreen} {win} {
    deleteWindows
    toplevel .t
    update
    wm attributes .t -alpha 1.0 -fullscreen 1
    wm attributes .t -fullscreen
} 1

test wm-attributes-1.3.12 {another attribute, then -fullscreen, then another} {win} {
    deleteWindows
    toplevel .t
    update
    wm attributes .t -toolwindow 0 -fullscreen 1 -topmost 0
    wm attributes .t -fullscreen
} 1

test wm-attributes-1.4.0 {setting/unsetting fullscreen does not change the focus} {win} {
    deleteWindows
    focus -force .
    toplevel .t
    lower .t
    update
    set results [list]
    lappend results [focus]

    wm attributes .t -fullscreen 1
    after 200 "set done 1" ; vwait done
    lappend results [focus]

    wm attributes .t -fullscreen 0
    after 200 "set done 1" ; vwait done
    lappend results [focus]

    set results
} {. . .}

test wm-attributes-1.4.1 {setting fullscreen does not generate FocusIn on wrapper create} {win} {
    deleteWindows
    catch {unset focusin}
    focus -force .
    toplevel .t
    pack [entry .t.e]
    lower .t
    bind .t <FocusIn> {lappend focusin %W}
    after 200 "set done 1" ; vwait done

    lappend focusin 1
    focus -force .t.e
    after 200 "set done 1" ; vwait done
    
    lappend focusin 2
    wm attributes .t -fullscreen 1
    after 200 "set done 1" ; vwait done

    lappend focusin 3
    wm attributes .t -fullscreen 0
    after 200 "set done 1" ; vwait done
    
    lappend focusin final [focus]

    bind . <FocusIn> {}
    bind .t <FocusIn> {}
    set focusin
} {1 .t .t.e 2 3 final .t.e}

test wm-attributes-1.5.0 {fullscreen stackorder} {win} {
    deleteWindows
    toplevel .t
    set results [list]
    lappend results [wm stackorder .]
    after 200 "set done 1" ; vwait done
    lappend results [wm stackorder .]

    # Default stacking is on top of other windows
    # on the display. Setting the fullscreen attribute
    # does not change this.
    wm attributes .t -fullscreen 1
    after 200 "set done 1" ; vwait done
    lappend results [wm stackorder .]

    set results
} {. {. .t} {. .t}}

test wm-attributes-1.5.1 {fullscreen stackorder} {win} {
    deleteWindows
    toplevel .t
    lower .t
    after 200 "set done 1" ; vwait done
    set results [list]
    lappend results [wm stackorder .]

    # If stacking order is explicitly set, then
    # setting the fullscreen attribute should
    # not change it.
    wm attributes .t -fullscreen 1
    after 200 "set done 1" ; vwait done
    lappend results [wm stackorder .]

    set results
} {{.t .} {.t .}}

test wm-attributes-1.5.2 {fullscreen stackorder} {win} {
    deleteWindows
    toplevel .t
    # lower forces the window to be mapped, it would not be otherwise
    lower .t
    set results [list]
    lappend results [wm stackorder .]

    # If stacking order is explicitly set
    # for an unmapped window, then setting
    # the fullscreen attribute should
    # not change it.
    wm attributes .t -fullscreen 1
    after 200 "set done 1" ; vwait done
    lappend results [wm stackorder .]

    set results
} {{.t .} {.t .}}

test wm-attributes-1.5.3 {fullscreen stackorder} {win} {
    deleteWindows
    toplevel .t
    after 200 "set done 1" ; vwait done
    set results [list]
    lappend results [wm stackorder .]

    wm attributes .t -fullscreen 1
    after 200 "set done 1" ; vwait done
    lappend results [wm stackorder .]

    # Unsetting the fullscreen attribute
    # should not change the stackorder.
    wm attributes .t -fullscreen 0
    after 200 "set done 1" ; vwait done
    lappend results [wm stackorder .]

    set results
} {{. .t} {. .t} {. .t}}

test wm-attributes-1.5.4 {fullscreen stackorder} {win} {
    deleteWindows
    toplevel .t
    lower .t
    after 200 "set done 1" ; vwait done
    set results [list]
    lappend results [wm stackorder .]

    wm attributes .t -fullscreen 1
    after 200 "set done 1" ; vwait done
    lappend results [wm stackorder .]

    # Unsetting the fullscreen attribute
    # should not change the stackorder.
    wm attributes .t -fullscreen 0
    after 200 "set done 1" ; vwait done
    lappend results [wm stackorder .]

    set results
} {{.t .} {.t .} {.t .}}

test wm-attributes-1.5.5 {fullscreen stackorder} {win} {
    deleteWindows
    toplevel .a
    toplevel .b
    toplevel .c
    raise .a
    raise .b
    raise .c
    after 200 "set done 1" ; vwait done
    set results [list]
    lappend results [wm stackorder .]

    wm attributes .b -fullscreen 1
    after 200 "set done 1" ; vwait done
    lappend results [wm stackorder .]

    # Unsetting the fullscreen attribute
    # should not change the stackorder.
    wm attributes .b -fullscreen 0
    after 200 "set done 1" ; vwait done
    lappend results [wm stackorder .]

    set results
} {{. .a .b .c} {. .a .b .c} {. .a .b .c}}
EOF
}
deleteWindows;
stdWindow;

{
    ### wm colormapwindows ###
    eval { $mw->colormapwindows("_","_") };
    like($@, qr{\Qwrong # args: should be "wm colormapwindows window ?windowList?"},
	 "wm colormapwindows usage");

    eval { $mw->colormapwindows("foo") };
    like($@, qr{bad window path name "foo"});
}

{
    my $t1 = $mw->Toplevel(qw(Name toplevel1 -width 200 -height 200 -colormap new));
    $t1->geometry("+0+0");
    my $t1a = $t1->Frame(qw(-width 100 -height 30));
    my $t1b = $t1->Frame(qw(-width 100 -height 30 -colormap new));
    Tk::pack($t1a, $t1b, qw(-side top));
    $mw->update;

    is_deeply([$t1->colormapwindows], [".toplevel1.frame1", ".toplevel1"],
	      "wm colormapwindows reading values");

    my $t1c = $t1->Frame(qw(-width 100 -height 30 -colormap new))->pack(-side => "top");
    $mw->update;
    is_deeply([$t1->colormapwindows], [".toplevel1.frame1", ".toplevel1.frame2", ".toplevel1"]);

    $t1->destroy;
}

{
    my $t1 = $mw->Toplevel(qw(Name toplevel2 -width 200 -height 200));
    $t1->geometry("+0+0");
    my @f;
    for (1 .. 3) {
	push @f, $t1->Frame(qw(-width 100 -height 30))->pack(-side => "top");
    }
    $t1->colormapwindows([$f[1], $f[0]]);
    is_deeply([$t1->colormapwindows], [".toplevel2.frame1", ".toplevel2.frame"],
	      "wm colormapwindows, setting and reading values");
}

{
    ### wm command ###
    eval { $mw->command("_", "_") };
    like($@, qr{\Qwrong # args: should be "wm command window ?value?"},
	 "wm command usage");

    is_deeply([$t->command],[], "wm command, setting and reading values");
    $t->command([qw(Miffo Foo)]);
    is_deeply([$t->command],[qw(Miffo Foo)]);
    $t->command(undef);
    is_deeply([$t->command],[]);
}

{
    ### wm deiconify ###
    my $icon = $mw->Toplevel(qw(Name icon -width 50 -height 50 -bg red));
    $t->iconwindow($icon);
    eval { $icon->deiconify };
    like($@, qr{can't deiconify .icon: it is an icon for .t}, "wm deiconify");
    $icon->destroy;
}

{
    if ($Tk::platform eq 'MSWin32') {
	# test embedded window for Windows
	my $tf = $t->Frame(-container => 1);
	my $embed = $mw->Toplevel(Name => "embed", -use => $tf->id);
	eval { $embed->deiconify };
	like($@, qr{\Qcan't deiconify .embed: the container does not support the request},
	     "wm deiconify embedded window");
	$embed->destroy;
	$tf->destroy;
    } else {
	my $tf = $t->Frame(-container => 1);
	my $embed = $mw->Toplevel(Name => "embed", -use => $tf->id);
	eval { $embed->deiconify };
	like($@, qr{\Qcan't deiconify .embed: it is an embedded window},
	     "wm deiconify embedded window");
	$embed->destroy;
	$tf->destroy;
    }
}

{
    deleteWindows;
    $t = $mw->Toplevel;
    $t->deiconify;
    ok(!$t->ismapped,
       q{a window that has never been mapped should not be mapped by deiconify()});
}

{
    deleteWindows;
    $t = $mw->Toplevel;
    $mw->idletasks;
    $t->withdraw;
    $t->deiconify;
    ok($t->ismapped,
       q{a window that has already been mapped should be mapped by deiconify()});
}

{
    deleteWindows;
    $t = $mw->Toplevel(qw(-width 200 -height 200));
    is($t->geometry, "1x1+0+0");
    $t->deiconify;
    is($t->geometry, "1x1+0+0",
       q{geometry for an unmapped window should not be calculated by deiconify()});
    $mw->idletasks;
    like($t->geometry, qr{^200x200},
	 q{... it should be done at idle time});
}

{
    deleteWindows;
    $t = $mw->Toplevel;
    $t->withdraw;
    $t->deiconify;
    $t->destroy;
    $mw->update;
    pass(q{invoking destroy after a deiconify should not result in a crash});
    # ... because of a callback set on the toplevel
}

{
    ### wm focusmodel ###
    eval { $mw->focusmodel("_", "_") };
    like($@, qr{\Qwrong # args: should be "wm focusmodel window ?active|passive?"},
	 "wm focusmodel usage");

    eval { $mw->focusmodel("bogus") };
    like($@, qr{\Qbad argument "bogus": must be active, or passive});
}

stdWindow;

{
    is($t->focusmodel, "passive",
       "wm focusmodel, setting and reading values");
    $t->focusmodel("active");
    is($t->focusmodel, "active");
    $t->focusmodel("passive");
    is($t->focusmodel, "passive");
}

{
    ### wm frame ###
    ok(defined $mw->frame, "wm frame");
}

{
    ### wm geometry ###
    eval { $mw->geometry("_", "_") };
    like($@, qr{\Qwrong # args: should be "wm geometry window ?newGeometry?"},
	 "wm geometry usage");

    eval { $mw->geometry("bogus") };
    like($@, qr{\Qbad geometry specifier "bogus"});
}

{
    $t->geometry("150x150+50+50");
    $t->update;
    is($t->geometry, "150x150+50+50",
       "wm geometry, setting and getting values");
    $t->geometry(undef);
    $t->update;
    isnt($t->geometry, "150x150+50+50", "geometry is now " . $t->geometry);
}

{
    ### wm grid ###
    for my $args (1, 3, 5) {
	eval { $mw->wmGrid(("_")x$args) };
	like($@, qr{\Qwrong # args: should be "wm grid window ?baseWidth baseHeight widthInc heightInc?"},
	     "wm grid usage (tried $args args)");
    }

    eval { $mw->wmGrid(qw(bad 14 16 16)) };
    like($@, qr{'bad' isn't numeric});

    eval { $mw->wmGrid(qw(13 foo 16 16)) };
    like($@, qr{'foo' isn't numeric});

    eval { $mw->wmGrid(qw(13 14 bar 16)) };
    like($@, qr{'bar' isn't numeric});

    eval { $mw->wmGrid(qw(13 14 15 baz)) };
    like($@, qr{'baz' isn't numeric});

    eval { $mw->wmGrid(qw(-1 14 15 16)) };
    like($@, qr{baseWidth can't be < 0});

    eval { $mw->wmGrid(qw(13 -1 15 16)) };
    like($@, qr{baseHeight can't be < 0});

    eval { $mw->wmGrid(qw(13 14 -1 16)) };
    like($@, qr{widthInc can't be <= 0});

    eval { $mw->wmGrid(qw(13 14 15 -1)) };
    like($@, qr{heightInc can't be <= 0});

    is_deeply([$t->wmGrid],[], "wm grid, setting and reading values");
    $t->wmGrid(qw(3 4 10 2));
    is_deeply([$t->wmGrid],[qw(3 4 10 2)]);
    $t->wmGrid((undef)x4);
    is_deeply([$t->wmGrid],[]);
}

{
    ### wm group ###
    eval { $mw->group(12, 13) };
    like($@, qr{\Qwrong # args: should be "wm group window ?pathName?"},
	 q{wm group usage});

    eval { $mw->group("bogus") };
    like($@, qr{bad window path name "bogus"});

    is($t->group, undef, "wm group, setting and reading values");
    $t->group($mw);
    is($t->group, ".");
    $t->group(undef);
    is($t->group, undef);
}

{
    ### wm iconbitmap ###
 SKIP: {
	skip("test only for unix", 1)
	    if $Tk::platform ne "unix";
	eval { $mw->iconbitmap(12, 13) };
	like($@, qr{\Qwrong # args: should be "wm iconbitmap window ?bitmap?"},
	     "wm iconbitmap usage on unix");
    }

 SKIP: {
	skip("test only for windows", 2)
	    if $Tk::platform ne "MSWin32";

	eval { $mw->iconbitmap(12, 13, 14) };
	like($@, qr{\Qwrong # args: should be "wm iconbitmap window ?-default? ?image?"},
	     "wm iconbitmap usage on windows");

	eval { $mw->iconbitmap(12, 13) };
	like($@, qr{\Qillegal option "12" must be "-default"});
    }

    eval { $mw->iconbitmap("bad-bitmap") };
    like($@, qr{bitmap "bad-bitmap" not defined});

    is($t->iconbitmap, undef, "wm iconbitmap, setting and reading values");
    $t->iconbitmap("hourglass");
    is($t->iconbitmap, "hourglass");
    $t->iconbitmap(undef);
    is($t->iconbitmap, undef);
}

{
    ### wm iconify ###
    my $t2 = $mw->Toplevel(qw(Name toplevel2));
    $t2->geometry("+10+10");
    $t2->overrideredirect(1);
    eval { $t2->iconify };
    like($@, qr{\Qcan't iconify ".toplevel2": override-redirect flag is set},
	 "wm iconify, misc errors");
    $t2->destroy;
}

{
    my $t2 = $mw->Toplevel(qw(Name toplevel2));
    $t2->geometry("+0+0");
    $t2->transient($t);
    eval { $t2->iconify };
    like($@, qr{\Qcan't iconify ".toplevel2": it is a transient});
    $t2->destroy;
}

{
    my $t2 = $mw->Toplevel(qw(Name toplevel2));
    $t2->geometry("+0+0");
    $t->iconwindow($t2);
    eval { $t2->iconify };
    like($@, qr{can't iconify .toplevel2: it is an icon for .toplevel});
    $t2->destroy;
}

{
    if ($Tk::platform eq 'MSWin32') {
	# test embedded window for Windows
	my $tf = $t->Frame(qw(Name f -container 1));
	my $t2 = $mw->Toplevel(qw(Name toplevel2), -use => $tf->id);
	eval { $t2->iconify };
	like($@, qr{\Qcan't iconify .toplevel2: the container does not support the request});
	$t2->destroy;
    } else {
	# test embedded window for other platforms
	my $tf = $t->Frame(qw(Name f -container 1));
	my $t2 = $mw->Toplevel(qw(Name toplevel2), -use => $tf->id);
	eval { $t2->iconify };
	like($@, qr{\Qcan't iconify .toplevel2: it is an embedded window});
	$t2->destroy;
    }
}

{
    my $t2 = $mw->Toplevel;
    $t2->geometry("-0+0");
    $mw->update;
    ok($t2->ismapped);
    $t2->iconify;
    $mw->update;
    ok(!$t2->ismapped);
}

{
    ### wm iconmask ###
    eval { $mw->iconmask(12, 13) };
    like($@, qr{\Qwrong # args: should be "wm iconmask window ?bitmap?"},
	 q{wm iconmask usage});

    eval { $mw->iconmask("bad-bitmap") };
    like($@, qr{\Qbitmap "bad-bitmap" not defined});

    is($t->iconmask, undef, "wm iconmask, setting and reading values");
    $t->iconmask("hourglass");
    is($t->iconmask, "hourglass");
    $t->iconmask(undef);
    is($t->iconmask, undef);
}

{
    ### wm iconname ###
    eval { $mw->iconname(12, 13) };
    like($@, qr{\Qwrong # args: should be "wm iconname window ?newName?"},
	 q{wm iconname usage});

    # This is somewhat inconsistent ('' vs. undef)
    is($t->iconname, '', "wm iconname, setting and reading values");
    $t->iconname("ThisIconHasAName");
    is($t->iconname, "ThisIconHasAName");
    $t->iconname(undef);
    is($t->iconname, '');
}

{
    ### wm iconphoto ###
    eval { $mw->iconphoto };
    like($@, qr{\Qwrong # args: should be "wm iconphoto window ?-default? image1 ?image2 ...?"},
	 "wm iconphoto usage");

    eval { $mw->iconphoto("notanimage") };
    like($@, qr{\Qcan't use "notanimage" as iconphoto: not a photo image});

    eval { $mw->iconphoto("-default") };
    like($@, qr{\Qwrong # args: should be "wm iconphoto window ?-default? image1 ?image2 ...?"});

    my $photo = $mw->Photo(-file => Tk->findINC("icon.gif"));
    $mw->iconphoto($photo);
    pass("Set iconphoto");

    # All other iconphoto tests are platform specific
}

{
    ### wm iconposition ###
    eval { $mw->iconposition(12) };
    like($@, qr{\Qwrong # args: should be "wm iconposition window ?x y?"},
	 "wm iconposition usage");

    eval { $mw->iconposition(12,13,14) };
    like($@, qr{\Qwrong # args: should be "wm iconposition window ?x y?"});

    eval { $mw->iconposition('bad', 13) };
    like($@, qr{\Q'bad' isn't numeric});

    eval { $mw->iconposition(13, 'lousy') };
    like($@, qr{\Q'lousy' isn't numeric});

    is_deeply([$mw->iconposition], [], "wm iconposition, setting and reading values");
    $mw->iconposition(10, 20);
    is_deeply([$mw->iconposition], [10, 20]);
    $mw->iconposition(undef, undef);
    is_deeply([$mw->iconposition], []);
}
__END__

### wm iconwindow ###
test wm-iconwindow-1.1 {usage} {
    list [catch {wm iconwindow} err] $err
} {1 {wrong # args: should be "wm option window ?arg ...?"}}
test wm-iconwindow-1.2 {usage} {
    list [catch {wm iconwindow .t 12 13} msg] $msg
} {1 {wrong # args: should be "wm iconwindow window ?pathName?"}}
test wm-iconwindow-1.3 {usage} {
    list [catch {wm iconwindow .t bogus} msg] $msg
} {1 {bad window path name "bogus"}}
test wm-iconwindow-1.4 {usage} -setup {
    destroy .b
} -body {
    button .b -text Help
    wm iconwindow .t .b
} -returnCodes error -cleanup {
    destroy .b
} -result {can't use .b as icon window: not at top level}
test wm-iconwindow-1.5 {usage} -setup {
    destroy .icon .t2
} -body {
    toplevel .icon -width 50 -height 50 -bg green
    toplevel .t2
    wm geom .t2 -0+0
    wm iconwindow .t2 .icon
    wm iconwindow .t .icon
} -returnCodes error -cleanup {
    destroy .t2 .icon
} -result {.icon is already an icon for .t2}

test wm-iconwindow-2.1 {setting and reading values} -setup {
    destroy .icon
} -body {
    set result {}
    lappend result [wm iconwindow .t]
    toplevel .icon -width 50 -height 50 -bg green
    wm iconwindow .t .icon
    lappend result [wm iconwindow .t]
    wm iconwindow .t {}
    destroy .icon
    lappend result [wm iconwindow .t]
} -result {{} .icon {}}


### wm maxsize ###
test wm-maxsize-1.1 {usage} {
    list [catch {wm maxsize} msg]  $msg
} {1 {wrong # args: should be "wm option window ?arg ...?"}}
test wm-maxsize-1.2 {usage} {
    list [catch {wm maxsize . a} msg]  $msg
} {1 {wrong # args: should be "wm maxsize window ?width height?"}}
test wm-maxsize-1.3 {usage} {
    list [catch {wm maxsize . a b c} msg]  $msg
} {1 {wrong # args: should be "wm maxsize window ?width height?"}}
test wm-maxsize-1.4 {usage} {
    list [catch {wm maxsize . x 100} msg]  $msg
} {1 {expected integer but got "x"}}
test wm-maxsize-1.5 {usage} {
    list [catch {wm maxsize . 100 bogus} msg]  $msg
} {1 {expected integer but got "bogus"}}
test wm-maxsize-1.6 {usage} -setup {
    destroy .t2
} -body {
    toplevel .t2
    wm maxsize .t2 300 200
    wm maxsize .t2
} -cleanup {
    destroy .t2
} -result {300 200}
test wm-maxsize-1.7 {maxsize must be <= screen size} -setup {
    destroy .t
} -body {
    toplevel .t
    foreach {t_width t_height} [wm maxsize .t] break
    set s_width [winfo screenwidth .t]
    set s_height [winfo screenheight .t]
    expr {($t_width <= $s_width) && ($t_height <= $s_height)}
} -result 1

test wm-maxsize-2.1 {setting the maxsize to a value smaller\
        than the current size will resize a toplevel} -setup {
    destroy .t
} -body {
    toplevel .t -width 300 -height 300
    update
    wm maxsize .t 200 150
    # UpdateGeometryInfo invoked at idle
    update
    lrange [split [wm geom .t] x+] 0 1
} -result {200 150}
test wm-maxsize-2.2 {setting the maxsize to a value smaller\
        than the current size will resize a gridded toplevel} -setup {
    destroy .t
} -body {
    toplevel .t
    wm grid .t 0 0 50 50
    wm geometry .t 6x6
    update
    wm maxsize .t 4 3
    # UpdateGeometryInfo invoked at idle
    update
    lrange [split [wm geom .t] x+] 0 1
} -result {4 3}
test wm-maxsize-2.3 {attempting to resize to a value\
        bigger than the current maxsize will set it to the max size} -setup {
    destroy .t
} -body {
    toplevel .t -width 200 -height 200
    wm maxsize .t 300 250
    update
    wm geom .t 400x300
    update
    lrange [split [wm geom .t] x+] 0 1
} -result {300 250}
test wm-maxsize-2.4 {attempting to resize to a value bigger than the\
	current maxsize will set it to the max size when gridded} -setup {
    destroy .t
} -body {
    toplevel .t
    wm grid .t 1 1 50 50
    wm geom .t 4x4
    wm maxsize .t 6 5
    update
    wm geom .t 8x6
    update
    lrange [split [wm geom .t] x+] 0 1
} -result {6 5}
test wm-maxsize-2.5 {Use max size if window size is not explicitly set\
	and the reqWidth/reqHeight are bigger than the max size} -setup {
    destroy .t
} -body {
    toplevel .t
    pack [frame .t.f -width 400 -height 400]
    update idletasks
    set req [list [winfo reqwidth .t] [winfo reqheight .t]]
    wm maxsize .t 300 300
    update
    list $req [lrange [split [wm geom .t] x+] 0 1]
} -result {{400 400} {300 300}}


### wm minsize ###
test wm-minsize-1.1 {usage} {
    list [catch {wm minsize} msg]  $msg
} {1 {wrong # args: should be "wm option window ?arg ...?"}}
test wm-minsize-1.2 {usage} {
    list [catch {wm minsize . a} msg]  $msg
} {1 {wrong # args: should be "wm minsize window ?width height?"}}
test wm-minsize-1.3 {usage} {
    list [catch {wm minsize . a b c} msg]  $msg
} {1 {wrong # args: should be "wm minsize window ?width height?"}}
test wm-minsize-1.4 {usage} {
    list [catch {wm minsize . x 100} msg]  $msg
} {1 {expected integer but got "x"}}
test wm-minsize-1.5 {usage} {
    list [catch {wm minsize . 100 bogus} msg]  $msg
} {1 {expected integer but got "bogus"}}
test wm-minsize-1.6 {usage} -setup {
    destroy .t2
} -body {
    toplevel .t2
    wm minsize .t2 300 200
    wm minsize .t2
} -cleanup {
    destroy .t2
} -result {300 200}

test wm-minsize-2.1 {setting the minsize to a value larger\
        than the current size will resize a toplevel} -setup {
    destroy .t
} -body {
    toplevel .t -width 200 -height 200
    update
    wm minsize .t 400 300
    # UpdateGeometryInfo invoked at idle
    update
    lrange [split [wm geom .t] x+] 0 1
} -result {400 300}
test wm-minsize-2.2 {setting the minsize to a value larger\
        than the current size will resize a gridded toplevel} -setup {
    destroy .t
} -body {
    toplevel .t
    wm grid .t 1 1 50 50
    wm geom .t 4x4
    update
    wm minsize .t 8 8
    # UpdateGeometryInfo invoked at idle
    update
    lrange [split [wm geom .t] x+] 0 1
} -result {8 8}
test wm-minsize-2.3 {attempting to resize to a value\
        smaller than the current minsize will set it to the minsize} -setup {
    destroy .t
} -body {
    toplevel .t -width 400 -height 400
    wm minsize .t 300 300
    update
    wm geom .t 200x200
    update
    lrange [split [wm geom .t] x+] 0 1
} -result {300 300}
test wm-minsize-2.4 {attempting to resize to a value smaller than the\
	current minsize will set it to the minsize when gridded} -setup {
    destroy .t
} -body {
    toplevel .t
    wm grid .t 1 1 50 50
    wm geom .t 8x8
    wm minsize .t 6 6
    update
    wm geom .t 4x4
    update
    lrange [split [wm geom .t] x+] 0 1
} -result {6 6}
test wm-minsize-2.5 {Use min size if window size is not explicitly set\
	and the reqWidth/reqHeight are smaller than the min size} -setup {
    destroy .t
} -body {
    toplevel .t
    pack [frame .t.f -width 250 -height 250]
    update idletasks
    set req [list [winfo reqwidth .t] \
                      [winfo reqheight .t]]
    wm minsize .t 300 300
    update
    list $req [lrange [split [wm geom .t] x+] 0 1]
} -result {{250 250} {300 300}}


### wm overrideredirect ###
test wm-overrideredirect-1.1 {usage} {
    list [catch {wm overrideredirect} msg]  $msg
} {1 {wrong # args: should be "wm option window ?arg ...?"}}
test wm-overrideredirect-1.2 {usage} {
    list [catch {wm overrideredirect .t 1 2} msg]  $msg
} {1 {wrong # args: should be "wm overrideredirect window ?boolean?"}}
test wm-overrideredirect-1.3 {usage} {
    list [catch {wm overrideredirect .t boo} msg]  $msg
} {1 {expected boolean value but got "boo"}}

test wm-overrideredirect-2.1 {setting and reading values} {
    set result {}
    lappend result [wm overrideredirect .t]
    wm overrideredirect .t true
    lappend result [wm overrideredirect .t]
    wm overrideredirect .t off
    lappend result [wm overrideredirect .t]
} {0 1 0}


### wm positionfrom ###
test wm-positionfrom-1.1 {usage} {
    list [catch {wm positionfrom} msg]  $msg
} {1 {wrong # args: should be "wm option window ?arg ...?"}}
test wm-positionfrom-1.2 {usage} {
    list [catch {wm positionfrom .t 1 2} msg]  $msg
} {1 {wrong # args: should be "wm positionfrom window ?user/program?"}}
test wm-positionfrom-1.3 {usage} {
    list [catch {wm positionfrom .t none} msg]  $msg
} {1 {bad argument "none": must be program or user}}

test wm-positionfrom-2.1 {setting and reading values} -setup {
    destroy .t2
} -body {
    toplevel .t2
    set result {}
    wm positionfrom .t user
    lappend result [wm positionfrom .t]
    wm positionfrom .t program
    lappend result [wm positionfrom .t]
    wm positionfrom .t {}
    lappend result [wm positionfrom .t]
} -cleanup {
    destroy .t2
} -result {user program {}}


### wm protocol ###
test wm-protocol-1.1 {usage} {
    list [catch {wm protocol} msg]  $msg
} {1 {wrong # args: should be "wm option window ?arg ...?"}}
test wm-protocol-1.2 {usage} {
    list [catch {wm protocol .t 1 2 3} msg]  $msg
} {1 {wrong # args: should be "wm protocol window ?name? ?command?"}}

test wm-protocol-2.1 {setting and reading values} {
    wm protocol .t {foo a} {a b c}
    wm protocol .t bar {test script for bar}
    set result [wm protocol .t]
    wm protocol .t {foo a} {}
    wm protocol .t bar {}
    set result
} {bar {foo a}}
test wm-protocol-2.2 {setting and reading values} {
    set result {}
    wm protocol .t foo {a b c}
    wm protocol .t bar {test script for bar}
    lappend result [wm protocol .t foo] [wm protocol .t bar]
    wm protocol .t foo {}
    wm protocol .t bar {}
    lappend result [wm protocol .t foo] [wm protocol .t bar]
} {{a b c} {test script for bar} {} {}}
test wm-protocol-2.3 {setting and reading values} {
    wm protocol .t foo {a b c}
    wm protocol .t foo {test script}
    set result [wm protocol .t foo]
    wm protocol .t foo {}
    set result
} {test script}


### wm resizable ###
test wm-resizable-1.1 {usage} {
    list [catch {wm resizable} msg]  $msg
} {1 {wrong # args: should be "wm option window ?arg ...?"}}
test wm-resizable-1.2 {usage} {
    list [catch {wm resizable .t 1} msg]  $msg
} {1 {wrong # args: should be "wm resizable window ?width height?"}}
test wm-resizable-1.3 {usage} {
    list [catch {wm resizable .t 1 2 3} msg]  $msg
} {1 {wrong # args: should be "wm resizable window ?width height?"}}
test wm-resizable-1.4 {usage} {
    list [catch {wm resizable .t bad 0} msg]  $msg
} {1 {expected boolean value but got "bad"}}
test wm-resizable-1.5 {usage} {
    list [catch {wm resizable .t 1 bad} msg]  $msg
} {1 {expected boolean value but got "bad"}}

test wm-resizable-2.1 {setting and reading values} {
    wm resizable .t 0 1
    set result [wm resizable .t]
    wm resizable .t 1 0
    lappend result [wm resizable .t]
    wm resizable .t 1 1
    lappend result [wm resizable .t]
} {0 1 {1 0} {1 1}}


### wm sizefrom ###
test wm-sizefrom-1.1 {usage} {
    list [catch {wm sizefrom} msg]  $msg
} {1 {wrong # args: should be "wm option window ?arg ...?"}}
test wm-sizefrom-1.2 {usage} {
    list [catch {wm sizefrom .t 1 2} msg]  $msg
} {1 {wrong # args: should be "wm sizefrom window ?user|program?"}}
test wm-sizefrom-1.4 {usage} {
    list [catch {wm sizefrom .t bad} msg]  $msg
} {1 {bad argument "bad": must be program or user}}

test wm-sizefrom-2.1 {setting and reading values} {
    set result [list [wm sizefrom .t]]
    wm sizefrom .t user
    lappend result [wm sizefrom .t]
    wm sizefrom .t program
    lappend result [wm sizefrom .t]
    wm sizefrom .t {}
    lappend result [wm sizefrom .t]
} {{} user program {}}


### wm stackorder ###
test wm-stackorder-1.1 {usage} {
    list [catch {wm stackorder} err] $err
} {1 {wrong # args: should be "wm option window ?arg ...?"}}
test wm-stackorder-1.2 {usage} {
    list [catch {wm stackorder . _} err] $err
} {1 {wrong # args: should be "wm stackorder window ?isabove|isbelow window?"}}
test wm-stackorder-1.3 {usage} {
    list [catch {wm stackorder . _ _ _} err] $err
} {1 {wrong # args: should be "wm stackorder window ?isabove|isbelow window?"}}
test wm-stackorder-1.4 {usage} {
    list [catch {wm stackorder . is .} err] $err
} {1 {ambiguous argument "is": must be isabove or isbelow}}
test wm-stackorder-1.5 {usage} {
    list [catch {wm stackorder _} err] $err
} {1 {bad window path name "_"}}
test wm-stackorder-1.6 {usage} {
    list [catch {wm stackorder . isabove _} err] $err
} {1 {bad window path name "_"}}
test wm-stackorder-1.7 {usage} -setup {
    destroy .t
} -body {
    toplevel .t
    button .t.b
    wm stackorder .t.b
} -returnCodes error -result {window ".t.b" isn't a top-level window}
test wm-stackorder-1.8 {usage} -setup {
    destroy .t
} -body {
    toplevel .t
    button .t.b
    pack .t.b
    update
    wm stackorder . isabove .t.b
} -returnCodes error -result {window ".t.b" isn't a top-level window}
test wm-stackorder-1.9 {usage} -setup {
    destroy .t
} -body {
    toplevel .t
    button .t.b
    pack .t.b
    update
    wm stackorder . isbelow .t.b
} -returnCodes error -result {window ".t.b" isn't a top-level window}
test wm-stackorder-1.10 {usage, isabove|isbelow toplevels must be mapped} -setup {
    destroy .t
} -body {
    toplevel .t
    update
    wm withdraw .t
    wm stackorder .t isabove .
} -returnCodes error -result {window ".t" isn't mapped}
test wm-stackorder-1.11 {usage, isabove|isbelow toplevels must be mapped} -setup {
    destroy .t
} -body {
    toplevel .t
    update
    wm withdraw .t
    wm stackorder . isbelow .t
} -returnCodes error -result {window ".t" isn't mapped}
deleteWindows

test wm-stackorder-2.1 {} -setup {
    destroy .t
} -body {
    toplevel .t ; update
    wm stackorder .
} -result {. .t}
test wm-stackorder-2.2 {} -setup {
    destroy .t
} -body {
    toplevel .t ; update
    raise .
    raiseDelay
    wm stackorder .
} -result {.t .}
test wm-stackorder-2.3 {} -setup {
    destroy .t .t2
} -body {
    toplevel .t ; update
    toplevel .t2 ; update
    raise .
    raise .t2
    raiseDelay
    wm stackorder .
} -result {.t . .t2}
test wm-stackorder-2.4 {} -setup {
    destroy .t .t2
} -body {
    toplevel .t ; update
    toplevel .t2 ; update
    raise .
    lower .t2
    raiseDelay
    wm stackorder .
} -result {.t2 .t .}
test wm-stackorder-2.5 {} {
    destroy .parent
    toplevel .parent ; update
    destroy .parent.child1
    toplevel .parent.child1 ; update
    destroy .parent.child2
    toplevel .parent.child2 ; update
    destroy .extra
    toplevel .extra ; update
    raise .parent
    lower .parent.child2
    raiseDelay
    wm stackorder .parent
} {.parent.child2 .parent.child1 .parent}
deleteWindows
test wm-stackorder-2.6 {non-toplevel widgets ignored} -setup {
    destroy .t1
} -body {
    toplevel .t1
    button .t1.b
    pack .t1.b
    update
    wm stackorder .
} -result {. .t1}
deleteWindows
test wm-stackorder-2.7 {no children returns self} {
    wm stackorder .
} {.}
deleteWindows

test wm-stackorder-3.1 {unmapped toplevel} -setup {
    destroy .t1 .t2
} -body {
    toplevel .t1 ; update
    toplevel .t2 ; update
    wm iconify .t1
    wm stackorder .
} -result {. .t2}
test wm-stackorder-3.2 {unmapped toplevel} -setup {
    destroy .t1 .t2
} -body {
    toplevel .t1 ; update
    toplevel .t2 ; update
    wm withdraw .t2
    wm stackorder .
} -result {. .t1}
test wm-stackorder-3.3 {unmapped toplevel} -setup {
    destroy .t1 .t2
} -body {
    toplevel .t1 ; update
    toplevel .t2 ; update
    wm withdraw .t2
    wm stackorder .t2
} -result {}
test wm-stackorder-3.4 {unmapped toplevel} -setup {
    destroy .t1
} -body {
    toplevel .t1 ; update
    toplevel .t1.t2 ; update
    wm withdraw .t1.t2
    wm stackorder .t1
} -result {.t1}
test wm-stackorder-3.5 {unmapped toplevel} -setup {
    destroy .t1
} -body {
    toplevel .t1 ; update
    toplevel .t1.t2 ; update
    wm withdraw .t1
    wm stackorder .t1
} -result {.t1.t2}
test wm-stackorder-3.6 {unmapped toplevel} -setup {
    destroy .t1
} -body {
    toplevel .t1 ; update
    toplevel .t1.t2 ; update
    toplevel .t1.t2.t3 ; update
    wm withdraw .t1.t2
    wm stackorder .t1
} -result {.t1 .t1.t2.t3}
test wm-stackorder-3.7 {unmapped toplevel, mapped children returned} -setup {
    destroy .t1
} -body {
    toplevel .t1 ; update
    toplevel .t1.t2 ; update
    wm withdraw .t1
    wm stackorder .t1
} -result {.t1.t2}
test wm-stackorder-3.8 {toplevel mapped in idle callback } -setup {
    destroy .t1
} -body {
    toplevel .t1
    wm stackorder .
} -result {.}
deleteWindows

test wm-stackorder-4.1 {wm stackorder isabove|isbelow} -setup {
    destroy .t
} -body {
    toplevel .t ; update
    raise .t
    wm stackorder . isabove .t
} -result {0}
test wm-stackorder-4.2 {wm stackorder isabove|isbelow} -setup {
    destroy .t
} -body {
    toplevel .t ; update
    raise .t
    wm stackorder . isbelow .t
} -result {1}
test wm-stackorder-4.3 {wm stackorder isabove|isbelow} -setup {
    destroy .t
} -body {
    toplevel .t ; update
    raise .
    raiseDelay
    wm stackorder .t isa .
} -result {0}
test wm-stackorder-4.4 {wm stackorder isabove|isbelow} -setup {
    destroy .t
} -body {
    toplevel .t ; update
    raise .
    raiseDelay
    wm stackorder .t isb .
} -result {1}
deleteWindows

test wm-stackorder-5.1 {a menu is not a toplevel} -setup {
    destroy .t
} -body {
    toplevel .t
    menu .t.m -type menubar
    .t.m add cascade -label "File"
    .t configure -menu .t.m
    update
    raise .
    raiseDelay
    wm stackorder .
} -result {.t .}
test wm-stackorder-5.2 {A normal toplevel can't be\
        raised above an overrideredirect toplevel} -setup {
    destroy .t
} -body {
    toplevel .t
    wm overrideredirect .t 1
    raise .
    update
    raiseDelay
    wm stackorder . isabove .t
} -result 0
test wm-stackorder-5.3 {An overrideredirect window\
        can be explicitly lowered} -setup {
    destroy .t
} -body {
    toplevel .t
    wm overrideredirect .t 1
    lower .t
    update
    raiseDelay
    wm stackorder .t isbelow .
} -result 1

test wm-stackorder-6.1 {An embedded toplevel does not\
        appear in the stacking order} -setup {
    deleteWindows
} -body {
    toplevel .real -container 1
    toplevel .embd -bg blue -use [winfo id .real]
    update
    wm stackorder .
} -result {. .real}

stdWindow


### wm title ###
test wm-title-1.1 {usage} {
    list [catch {wm title} msg]  $msg
} {1 {wrong # args: should be "wm option window ?arg ...?"}}
test wm-title-1.2 {usage} {
    list [catch {wm title . 1 2} msg]  $msg
} {1 {wrong # args: should be "wm title window ?newTitle?"}}

test wm-title-2.1 {setting and reading values} {
    destroy .t
    toplevel .t
    set result [wm title .t]
    wm title .t Apa
    lappend result [wm title .t]
    wm title .t {}
    lappend result [wm title .t]
} {t Apa {}}


### wm transient ###
test wm-transient-1.1 {usage} {
    catch {destroy .t} ; toplevel .t
    list [catch {wm transient .t 1 2} msg]  $msg
} {1 {wrong # args: should be "wm transient window ?master?"}}
test wm-transient-1.2 {usage} {
    catch {destroy .t} ; toplevel .t
    list [catch {wm transient .t foo} msg]  $msg
} {1 {bad window path name "foo"}}
test wm-transient-1.3 {usage} {
    catch {destroy .t} ; toplevel .t
    list [catch {wm transient foo .t} msg]  $msg
} {1 {bad window path name "foo"}}
test wm-transient-1.4 {usage} {
    deleteWindows
    toplevel .master
    toplevel .subject
    wm transient .subject .master
    list [catch {wm iconify .subject} msg] $msg
} {1 {can't iconify ".subject": it is a transient}}
test wm-transient-1.5 {usage} {
    deleteWindows
    toplevel .icon -bg blue
    toplevel .top
    wm iconwindow .top .icon
    toplevel .dummy
    list [catch {wm transient .icon .dummy} msg] $msg
} {1 {can't make ".icon" a transient: it is an icon for .top}}
test wm-transient-1.6 {usage} {
    deleteWindows
    toplevel .icon -bg blue
    toplevel .top
    wm iconwindow .top .icon
    toplevel .dummy
    list [catch {wm transient .dummy .icon} msg] $msg
} {1 {can't make ".icon" a master: it is an icon for .top}}
test wm-transient-1.7 {usage} {
    deleteWindows
    toplevel .master
    list [catch {wm transient .master .master} err] $err
} {1 {can't make ".master" its own master}}
test wm-transient-1.8 {usage} {
    deleteWindows
    toplevel .master
    frame .master.f
    list [catch {wm transient .master .master.f} err] $err
} {1 {can't make ".master" its own master}}

test wm-transient-2.1 { basic get/set of master } {
    deleteWindows
    set results [list]    
    toplevel .master
    toplevel .subject
    lappend results [wm transient .subject]
    wm transient .subject .master
    lappend results [wm transient .subject]
    wm transient .subject {}
    lappend results [wm transient .subject]
    set results
} {{} .master {}}
test wm-transient-2.2 { first toplevel parent of
        non-toplevel master is used } {
    deleteWindows
    toplevel .master
    frame .master.f
    toplevel .subject
    wm transient .subject .master.f
    wm transient .subject
} {.master}

test wm-transient-3.1 { transient toplevel is withdrawn
        when mapped if master is withdrawn } {
    deleteWindows
    toplevel .master
    wm withdraw .master
    update
    toplevel .subject
    wm transient .subject .master
    update
    list [wm state .subject] [winfo ismapped .subject]
} {withdrawn 0}
test wm-transient-3.2 { already mapped transient toplevel
        takes on withdrawn state of master } {
    deleteWindows
    toplevel .master
    wm withdraw .master
    update
    toplevel .subject
    update
    wm transient .subject .master
    update
    list [wm state .subject] [winfo ismapped .subject]
} {withdrawn 0}
test wm-transient-3.3 { withdraw/deiconify on the master
        also does a withdraw/deiconify on the transient } {
    deleteWindows
    set results [list]
    toplevel .master
    toplevel .subject
    update
    wm transient .subject .master
    wm withdraw .master
    update
    lappend results [wm state .subject] \
        [winfo ismapped .subject]
    wm deiconify .master
    update
    lappend results [wm state .subject] \
        [winfo ismapped .subject]
    set results
} {withdrawn 0 normal 1}

test wm-transient-4.1 { transient toplevel is withdrawn
        when mapped if master is iconic } {
    deleteWindows
    toplevel .master
    wm iconify .master
    update
    toplevel .subject
    wm transient .subject .master
    update
    list [wm state .subject] [winfo ismapped .subject]
} {withdrawn 0}
test wm-transient-4.2 { already mapped transient toplevel
        is withdrawn if master is iconic } {
    deleteWindows
    toplevel .master
    wm iconify .master
    update
    toplevel .subject
    update
    wm transient .subject .master
    update
    list [wm state .subject] [winfo ismapped .subject]
} {withdrawn 0}
test wm-transient-4.3 { iconify/deiconify on the master
        does a withdraw/deiconify on the transient } {
    deleteWindows
    set results [list]
    toplevel .master
    toplevel .subject
    update
    wm transient .subject .master
    wm iconify .master
    update
    lappend results [wm state .subject] \
        [winfo ismapped .subject]
    wm deiconify .master
    update
    lappend results [wm state .subject] \
        [winfo ismapped .subject]
    set results
} {withdrawn 0 normal 1}

test wm-transient-5.1 { an error during transient command should not
        cause the map/unmap binding to be deleted } {
    deleteWindows
    set results [list]
    toplevel .master
    toplevel .subject
    update
    wm transient .subject .master
    # Expect a bad window path error here
    lappend results [catch {wm transient .subject .bad}]
    wm withdraw .master
    update
    lappend results [wm state .subject]
    wm deiconify .master
    update
    lappend results [wm state .subject]
    set results
} {1 withdrawn normal}
test wm-transient-5.2 { remove transient property when master
        is destroyed } {
    deleteWindows
    toplevel .master
    toplevel .subject
    wm transient .subject .master
    update
    destroy .master
    update
    wm transient .subject
} {}
test wm-transient-5.3 { remove transient property from window
        that had never been mapped when master is destroyed } {
    deleteWindows
    toplevel .master
    toplevel .subject
    wm transient .subject .master
    destroy .master
    wm transient .subject
} {}

test wm-transient-6.1 { a withdrawn transient does not track
        state changes in the master } {
    deleteWindows
    toplevel .master
    toplevel .subject
    update
    wm transient .subject .master
    wm withdraw .subject
    wm withdraw .master
    wm deiconify .master
    # idle handler should not map the transient
    update
    wm state .subject
} {withdrawn}
test wm-transient-6.2 { a withdrawn transient does not track
        state changes in the master } {
    set results [list]
    deleteWindows
    toplevel .master
    toplevel .subject
    update
    wm transient .subject .master
    wm withdraw .subject
    wm withdraw .master
    wm deiconify .master
    # idle handler should not map the transient
    update
    lappend results [wm state .subject]
    wm deiconify .subject
    lappend results [wm state .subject]
    wm withdraw .master
    lappend results [wm state .subject]
    wm deiconify .master
    # idle handler should map transient
    update
    lappend results [wm state .subject]
} {withdrawn normal withdrawn normal}
test wm-transient-6.3 { a withdrawn transient does not track
        state changes in the master } {
    deleteWindows
    toplevel .master
    toplevel .subject
    update
    # withdraw before making window a transient
    wm withdraw .subject
    wm transient .subject .master
    wm withdraw .master
    wm deiconify .master
    # idle handler should not map the transient
    update
    wm state .subject
} {withdrawn}

# wm-transient-7.*: See SF Tk Bug #592201 "wm transient fails with two masters"
# wm-transient-7.3 through 7.5 all caused panics on Unix in Tk 8.4b1.
# 7.1 and 7.2 added to catch (potential) future errors.
#
test wm-transient-7.1 {Destroying transient} {
    deleteWindows
    toplevel .t 
    toplevel .transient 
    wm transient .transient .t
    destroy .transient
    destroy .t
    # OK: the above did not cause a panic.
} {}
test wm-transient-7.2 {Destroying master} {
    deleteWindows
    toplevel .t
    toplevel .transient 
    wm transient .transient .t
    destroy .t
    set result [wm transient .transient]
    destroy .transient
    set result
} {}
test wm-transient-7.3 {Reassign transient, destroy old master} {
    deleteWindows
    toplevel .t1 
    toplevel .t2 
    toplevel .transient
    wm transient .transient .t1
    wm transient .transient .t2
    destroy .t1	;# Caused panic in 8.4b1
    destroy .t2 
    destroy .transient
} {}
test wm-transient-7.4 {Reassign transient, destroy new master} {
    deleteWindows
    toplevel .t1 
    toplevel .t2 
    toplevel .transient
    wm transient .transient .t1
    wm transient .transient .t2
    destroy .t2 	;# caused panic in 8.4b1
    destroy .t1
    destroy .transient
} {}
test wm-transient-7.5 {Reassign transient, destroy transient} {
    deleteWindows
    toplevel .t1 
    toplevel .t2 
    toplevel .transient
    wm transient .transient .t1
    wm transient .transient .t2
    destroy .transient
    destroy .t2 	;# caused panic in 8.4b1
    destroy .t1		;# so did this
} {}


### wm state ###
test wm-state-1.1 {usage} {
    list [catch {wm state} err] $err
} {1 {wrong # args: should be "wm option window ?arg ...?"}}
test wm-state-1.2 {usage} {
    list [catch {wm state . _ _} err] $err
} {1 {wrong # args: should be "wm state window ?state?"}}

test wm-state-2.1 {initial state} {
    deleteWindows
    toplevel .t
    wm state .t
} {normal}
test wm-state-2.2 {state change before map} {
    deleteWindows
    toplevel .t
    wm state .t withdrawn
    wm state .t
} {withdrawn}
test wm-state-2.3 {state change before map} {
    deleteWindows
    toplevel .t
    wm withdraw .t
    wm state .t
} {withdrawn}
test wm-state-2.4 {state change after map} {
    deleteWindows
    toplevel .t
    update
    wm state .t withdrawn
    wm state .t
} {withdrawn}
test wm-state-2.5 {state change after map} {
    deleteWindows
    toplevel .t
    update
    wm withdraw .t
    wm state .t
} {withdrawn}
test wm-state-2.6 {state change before map} {
    deleteWindows
    toplevel .t
    wm state .t iconic
    wm state .t
} {iconic}
test wm-state-2.7 {state change before map} {
    deleteWindows
    toplevel .t
    wm iconify .t
    wm state .t
} {iconic}
test wm-state-2.8 {state change after map} {
    deleteWindows
    toplevel .t
    update
    wm state .t iconic
    wm state .t
} {iconic}
test wm-state-2.9 {state change after map} {
    deleteWindows
    toplevel .t
    update
    wm iconify .t
    wm state .t
} {iconic}
test wm-state-2.10 {state change before map} {
    deleteWindows
    toplevel .t
    wm withdraw .t
    wm state .t normal
    wm state .t
} {normal}
test wm-state-2.11 {state change before map} {
    deleteWindows
    toplevel .t
    wm withdraw .t
    wm deiconify .t
    wm state .t
} {normal}
test wm-state-2.12 {state change after map} {
    deleteWindows
    toplevel .t
    update
    wm withdraw .t
    wm state .t normal
    wm state .t
} {normal}
test wm-state-2.13 {state change after map} {
    deleteWindows
    toplevel .t
    update
    wm withdraw .t
    wm deiconify .t
    wm state .t
} {normal}
test wm-state-2.14 {state change before map} {
    deleteWindows
    toplevel .t
    wm iconify .t
    wm state .t normal
    wm state .t
} {normal}
test wm-state-2.15 {state change before map} {
    deleteWindows
    toplevel .t
    wm iconify .t
    wm deiconify .t
    wm state .t
} {normal}
test wm-state-2.16 {state change after map} {
    deleteWindows
    toplevel .t
    update
    wm iconify .t
    wm state .t normal
    wm state .t
} {normal}
test wm-state-2.17 {state change after map} {
    deleteWindows
    toplevel .t
    update
    wm iconify .t
    wm deiconify .t
    wm state .t
} {normal}
test wm-state-2.18 {state change after map} win {
    deleteWindows
    toplevel .t
    update
    wm state .t zoomed
    wm state .t
} {zoomed}


### wm withdraw ###
test wm-withdraw-1.1 {usage} {
    list [catch {wm withdraw} err] $err
} {1 {wrong # args: should be "wm option window ?arg ...?"}}
test wm-withdraw-1.2 {usage} {
    list [catch {wm withdraw . _} msg] $msg
} {1 {wrong # args: should be "wm withdraw window"}}

test wm-withdraw-2.1 {Misc errors} -setup {
    deleteWindows
} -body {
    toplevel .t
    toplevel .t2
    wm iconwindow .t .t2
    wm withdraw .t2
} -returnCodes error -cleanup {
    destroy .t2
} -result {can't withdraw .t2: it is an icon for .t}

test wm-withdraw-3.1 {} {
    update
    set result {}
    wm withdraw .t
    lappend result [wm state .t] [winfo ismapped .t]
    wm deiconify .t
    lappend result [wm state .t] [winfo ismapped .t]
} {withdrawn 0 normal 1}


### Misc. wm tests ###
test wm-deletion-epoch-1.1 {Deletion epoch on multiple displays} -constraints altDisplay -setup {
    deleteWindows
} -body {
    # See Tk Bug #671330 "segfault when e.g. deiconifying destroyed window"
    set w [toplevel .t -screen $env(TK_ALT_DISPLAY)]
    wm deiconify $w         ;# this caches the WindowRep
    destroy .t
    wm deiconify $w
} -returnCodes error -result {bad window path name ".t"}

# FIXME:

# Test delivery of virtual events to the WM. We could check to see
# if the window was raised after a button click for example.
# This sort of testing may not be possible.

deleteWindows
cleanupTests
catch {unset results}
catch {unset focusin}
return


__END__
