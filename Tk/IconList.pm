# -*- perl -*-
#
# tkfbox.tcl --
#
#       Implements the "TK" standard file selection dialog box. This
#       dialog box is used on the Unix platforms whenever the tk_strictMotif
#       flag is not set.
#
#       The "TK" standard file selection dialog box is similar to the
#       file selection dialog box on Win95(TM). The user can navigate
#       the directories by clicking on the folder icons or by
#       selectinf the "Directory" option menu. The user can select
#       files by clicking on the file icons or by entering a filename
#       in the "Filename:" entry.
#
# Copyright (c) 1994-1996 Sun Microsystems, Inc.
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# Translated to perk/Tk by Slaven Rezic <eserte@cs.tu-berlin.de>.
#

#----------------------------------------------------------------------
#
#		      I C O N   L I S T
#
# This is a pseudo-widget that implements the icon list inside the
# tkFDialog dialog box.
#
#----------------------------------------------------------------------
# tkIconList --
#
#	Creates an IconList widget.
#

package Tk::IconList;
require Tk::Frame;
use strict;

use vars qw($VERSION);
$VERSION = '3.005'; # $Id: //depot/Tk8/Tk/IconList.pm#5 $

use base 'Tk::Frame';

Construct Tk::Widget 'IconList';

# tkIconList_Create --
#
#	Creates an IconList widget by assembling a canvas widget and a
#	scrollbar widget. Sets all the bindings necessary for the IconList's
#	operations.
#
sub Populate {
    my($w, $args) = @_;
    $w->SUPER::Populate($args);

    my $sbar = $w->Component('Scrollbar' => 'sbar',
			     -orient => 'horizontal',
			     -highlightthickness => 0,
			     -takefocus => 0,
			    );
    my $canvas = $w->Component('Canvas' => 'canvas',
			       -bd => 2,
			       -relief => 'sunken',
			       -width => 400,
			       -height => 120,
			       -takefocus => 1,
			      );
    $sbar->pack(-side => 'bottom', -fill => 'x', -padx => 2);
    $canvas->pack(-expand => 'yes', -fill => 'both');
    $sbar->configure(-command => ['xview', $canvas]);
    $canvas->configure(-xscrollcommand => ['set', $sbar]);

    # Initializes the max icon/text width and height and other variables
    $w->{'maxIW'} = 1;
    $w->{'maxIH'} = 1;
    $w->{'maxTW'} = 1;
    $w->{'maxTH'} = 1;
    $w->{'numItems'} = 0;
    delete $w->{'curItem'};
    $w->{'noScroll'} = 1;

    # Creates the event bindings.
    $canvas->Tk::bind('<Configure>', sub { $w->Arrange } );
    $canvas->Tk::bind('<1>',
		      sub {
			  my $c = shift;
			  my $Ev = $c->XEvent;
			  $w->Btn1($Ev->x, $Ev->y);
		      }
		     );
    $canvas->Tk::bind('<B1-Motion>',
		      sub {
			  my $c = shift;
			  my $Ev = $c->XEvent;
			  $w->Motion1($Ev->x, $Ev->y);
		      }
		     );
    $canvas->Tk::bind('<Double-ButtonRelease-1>',
		      sub {
			  my $c = shift;
			  my $Ev = $c->XEvent;
			  $w->Double1($Ev->x,$Ev->y);
		      }
		     );
    $canvas->Tk::bind('<ButtonRelease-1>', sub { $w->CancelRepeat });
    $canvas->Tk::bind('<B1-Leave>',
		      sub {
			  my $c = shift;
			  my $Ev = $c->XEvent;
			  $w->Leave1($Ev->x, $Ev->y);
		      }
		     );
    $canvas->Tk::bind('<B1-Enter>', sub { $w->CancelRepeat });
    $canvas->Tk::bind('<Up>',     sub { $w->UpDown(-1) });
    $canvas->Tk::bind('<Down>',   sub { $w->UpDown(1)  });
    $canvas->Tk::bind('<Left>',   sub { $w->LeftRight(-1) });
    $canvas->Tk::bind('<Right>',  sub { $w->LeftRight(1) });
    $canvas->Tk::bind('<Return>', sub { $w->ReturnKey });
    $canvas->Tk::bind('<KeyPress>',
		      sub {
			  my $c = shift;
			  my $Ev = $c->XEvent;
			  $w->KeyPress($Ev->A);
		      }
		     );
    $canvas->Tk::bind('<Control-KeyPress>', 'NoOp');
    $canvas->Tk::bind('<Alt-KeyPress>', 'NoOp');
    $canvas->Tk::bind('<FocusIn>', sub { $w->FocusIn });

    $w->ConfigSpecs(-browsecmd =>
		    ['CALLBACK', 'browseCommand', 'BrowseCommand', undef],
		    -command =>
		    ['CALLBACK', 'command', 'Command', undef],
		    -font =>
		    ['PASSIVE', 'font', 'Font', undef],
		    -foreground =>
		    ['PASSIVE', 'foreground', 'Foreground', undef],
		    -fg => '-foreground',
		   );

    $w;
}

# tkIconList_AutoScan --
#
# This procedure is invoked when the mouse leaves an entry window
# with button 1 down.  It scrolls the window up, down, left, or
# right, depending on where the mouse left the window, and reschedules
# itself as an "after" command so that the window continues to scroll until
# the mouse moves back into the window or the mouse button is released.
#
# Arguments:
# w -		The IconList window.
#
sub AutoScan {
    my $w = shift;
    return unless ($w->exists);
    return if ($w->{'noScroll'});
    my($x, $y);
    $x = $Tk::x;
    $y = $Tk::y;
    my $canvas = $w->Subwidget('canvas');
    if ($x >= $canvas->width) {
	$canvas->xview('scroll', 1, 'units');
    } elsif ($x < 0) {
	$canvas->xview('scroll', -1, 'units');
    } elsif ($y >= $canvas->height) {
	# do nothing
    } elsif ($y < 0) {
	# do nothing
    } else {
	return;
    }
    $w->Motion1($x, $y);
    $w->RepeatId($w->after(50, ['AutoScan', $w]));
}

# Deletes all the items inside the canvas subwidget and reset the IconList's
# state.
#
sub DeleteAll {
    my $w = shift;
    my $canvas = $w->Subwidget('canvas');
    $canvas->delete('all');
    delete $w->{'selected'};
    delete $w->{'rect'};
    delete $w->{'list'};
    delete $w->{'itemList'};
    $w->{'maxIW'} = 1;
    $w->{'maxIH'} = 1;
    $w->{'maxTW'} = 1;
    $w->{'maxTH'} = 1;
    $w->{'numItems'} = 0;
    delete $w->{'curItem'};
    $w->{'noScroll'} = 1;
    $w->Subwidget('sbar')->set(0.0, 1.0);
    $canvas->xview('moveto', 0);
}

# Adds an icon into the IconList with the designated image and text
#
sub Add {
    my($w, $image, $text) = @_;
    my $canvas = $w->Subwidget('canvas');
    my $iTag = $canvas->createImage(0, 0, -image => $image, -anchor => 'nw');
    my $font = $w->cget(-font);
    my $fg   = $w->cget(-foreground);
    my $tTag = $canvas->createText(0, 0, -text => $text, -anchor => 'nw',
				   (defined $fg   ? (-fill => $fg)   : ()),
				   (defined $font ? (-font => $font) : ()),
				  );
    my $rTag = $canvas->createRectangle(0, 0, 0, 0,
					-fill => undef,
					-outline => undef);
    my(@b) = $canvas->bbox($iTag);
    my $iW = $b[2] - $b[0];
    my $iH = $b[3] - $b[1];
    $w->{'maxIW'} = $iW if ($w->{'maxIW'} < $iW);
    $w->{'maxIH'} = $iH if ($w->{'maxIH'} < $iH);
    @b = $canvas->bbox($tTag);
    my $tW = $b[2] - $b[0];
    my $tH = $b[3] - $b[1];
    $w->{'maxTW'} = $tW if ($w->{'maxTW'} < $tW);
    $w->{'maxTH'} = $tH if ($w->{'maxTH'} < $tH);
    push @{ $w->{'list'} }, [$iTag, $tTag, $rTag, $iW, $iH, $tW, $tH,
			     $w->{'numItems'}];
    $w->{'itemList'}{$rTag} = [$iTag, $tTag, $text, $w->{'numItems'}];
    $w->{'textList'}{$w->{'numItems'}} = lc($text);
    ++$w->{'numItems'};
}

# Places the icons in a column-major arrangement.
#
sub Arrange {
    my $w = shift;
    my $canvas = $w->Subwidget('canvas');
    my $sbar   = $w->Subwidget('sbar');
    unless (exists $w->{'list'}) {
	if (defined $canvas && Tk::Exists($canvas)) {
	    $w->{'noScroll'} = 1;
	    $sbar->configure(-command => sub { });
	}
	return;
    }

    my $W = $canvas->width;
    my $H = $canvas->height;
    my $pad = $canvas->cget(-highlightthickness) + $canvas->cget(-bd);
    $pad = 2 if ($pad < 2);
    $W -= $pad*2;
    $H -= $pad*2;
    my $dx = $w->{'maxIW'} + $w->{'maxTW'} + 8;
    my $dy;
    if ($w->{'maxTH'} > $w->{'maxIH'}) {
	$dy = $w->{'maxTH'};
    } else {
	$dy = $w->{'maxIH'};
    }
    $dy += 2;
    my $shift = $w->{'maxIW'} + 4;
    my $x = $pad * 2;
    my $y = $pad;
    my $usedColumn = 0;
    foreach my $sublist (@{ $w->{'list'} }) {
	$usedColumn = 1;
	my($iTag, $tTag, $rTag, $iW, $iH, $tW, $tH) = @$sublist;
	my $i_dy = ($dy - $iH) / 2;
	my $t_dy = ($dy - $tH) / 2;
	$canvas->coords($iTag, $x, $y + $i_dy);
	$canvas->coords($tTag, $x + $shift, $y + $t_dy);
	$canvas->coords($tTag, $x + $shift, $y + $t_dy);
	$canvas->coords($rTag, $x, $y, $x + $dx, $y + $dy);
	$y += $dy;
	if ($y + $dy > $H) {
	    $y = $pad;
	    $x += $dx;
	    $usedColumn = 0;
	}
    }
    my $sW;
    if ($usedColumn) {
	$sW = $x + $dx;
    } else {
	$sW = $x;
    }
    if ($sW < $W) {
	$canvas->configure(-scrollregion => [$pad, $pad, $sW, $H]);
	$sbar->configure(-command => sub { });
	$canvas->xview(moveto => 0);
	$w->{'noScroll'} = 1;
    } else {
	$canvas->configure(-scrollregion => [$pad, $pad, $sW, $H]);
	$sbar->configure(-command => ['xview', $canvas]);
	$w->{'noScroll'} = 0;
    }
    $w->{'itemsPerColumn'} = ($H - $pad) / $dy;
    $w->{'itemsPerColumn'} = 1 if ($w->{'itemsPerColumn'} < 1);
    $w->Select($w->{'list'}[$w->{'curItem'}][2], 0)
      if (exists $w->{'curItem'});
}

# Gets called when the user invokes the IconList (usually by double-clicking
# or pressing the Return key).
#
sub Invoke {
    my $w = shift;
    $w->Callback(-command => $w->{'selected'}) if (exists $w->{'selected'});
}

# tkIconList_See --
#
#	If the item is not (completely) visible, scroll the canvas so that
#	it becomes visible.
sub See {
    my($w, $rTag) = @_;
    return if ($w->{'noScroll'});
    return unless (exists $w->{'itemList'}{$rTag});
    my $canvas = $w->Subwidget('canvas');
    my(@sRegion) = @{ $canvas->cget('-scrollregion') };
    return unless (@sRegion);
    my(@bbox) = $canvas->bbox($rTag);
    my $pad = $canvas->cget(-highlightthickness) + $canvas->cget(-bd);
    my $x1 = $bbox[0];
    my $x2 = $bbox[2];
    $x1 -= $pad * 2;
    $x2 -= $pad;
    my $cW = $canvas->width - $pad * 2;
    my $scrollW = $sRegion[2] - $sRegion[0] + 1;
    my $dispX = int(($canvas->xview)[0] * $scrollW);
    my $oldDispX = $dispX;
    # check if out of the right edge
    $dispX = $x2 - $cW if ($x2 - $dispX >= $cW);
    # check if out of the left edge
    $dispX = $x1 if ($x1 - $dispX < 0);
    if ($oldDispX != $dispX) {
	my $fraction = $dispX / $scrollW;
	$canvas->xview('moveto', $fraction);
    }
}

sub SelectAtXY {
    my($w, $x, $y) = @_;
    my $canvas = $w->Subwidget('canvas');
    $w->Select($canvas->find('closest',
			     $canvas->canvasx($x),
			     $canvas->canvasy($y)));
}

sub Select {
    my $w = shift;
    my $rTag = shift;
    my $callBrowse = (@_ ? shift : 1);
    return unless (exists $w->{'itemList'}{$rTag});
    my($iTag, $tTag, $text, $serial) = @{ $w->{'itemList'}{$rTag} };
    my $canvas = $w->Subwidget('canvas');
    $w->{'rect'} = $canvas->createRectangle(0, 0, 0, 0, -fill => '#a0a0ff',
					    -outline => '#a0a0ff')
      unless (exists $w->{'rect'});
    $canvas->lower($w->{'rect'});
    my(@bbox) = $canvas->bbox($tTag);
    $canvas->coords($w->{'rect'}, @bbox);
    $w->{'curItem'} = $serial;
    $w->{'selected'} = $text;
    if ($callBrowse) {
	$w->Callback(-browsecmd => $text);
    }
}

sub Unselect {
    my $w = shift;
    my $canvas = $w->Subwidget('canvas');
    if (exists $w->{'rect'}) {
	$canvas->delete($w->{'rect'});
	delete $w->{'rect'};
    }
    delete $w->{'selected'} if (exists $w->{'selected'});
    delete $w->{'curItem'};
}

# Returns the selected item
#
sub Get {
    my $w = shift;
    if (exists $w->{'selected'}) {
	$w->{'selected'};
    } else {
	undef;
    }
}

sub Btn1 {
    my($w, $x, $y) = @_;
    $w->Subwidget('canvas')->focus;
    $w->SelectAtXY($x, $y);
}

# Gets called on button-1 motions
#
sub Motion1 {
    my($w, $x, $y) = @_;
    $Tk::x = $x;
    $Tk::y = $y;
    $w->SelectAtXY($x, $y);
}

sub Double1 {
    my($w, $x, $y) = @_;
    $w->Invoke if (exists $w->{'curItem'});
}

sub ReturnKey {
    my $w = shift;
    $w->Invoke;
}

sub Leave1 {
    my($w, $x, $y) = @_;
    $Tk::x = $x;
    $Tk::y = $y;
    $w->AutoScan;
}

sub FocusIn {
    my $w = shift;
    return unless (exists $w->{'list'});
    unless (exists $w->{'curItem'}) {
	my $rTag = $w->{'list'}[0][2];
	$w->Select($rTag);
    }
}

# tkIconList_UpDown --
#
# Moves the active element up or down by one element
#
# Arguments:
# w -		The IconList widget.
# amount -	+1 to move down one item, -1 to move back one item.
#
sub UpDown {
    my($w, $amount) = @_;
    my $rTag;
    return unless (exists $w->{'list'});
    unless (exists $w->{'curItem'}) {
	$rTag = $w->{'list'}[0][2];
    } else {
	my $oldRTag = $w->{'list'}[$w->{'curItem'}][2];
	$rTag = $w->{'list'}[($w->{'curItem'} + $amount)][2];
	$rTag = $oldRTag unless defined $rTag;
    }
    if (defined $rTag) {
	$w->Select($rTag);
	$w->See($rTag);
    }
}

# tkIconList_LeftRight --
#
# Moves the active element left or right by one column
#
# Arguments:
# w -		The IconList widget.
# amount -	+1 to move right one column, -1 to move left one column.
#
sub LeftRight {
    my($w, $amount) = @_;
    my $rTag;
    return unless (exists $w->{'list'});
    unless (exists $w->{'curItem'}) {
	$rTag = $w->{'list'}[0][2];
    } else {
	my $oldRTag = $w->{'list'}[$w->{'curItem'}][2];
	my $newItem = $w->{'curItem'} + $amount * $w->{'itemsPerColumn'};
	$rTag = $w->{'list'}[$newItem][2];
	$rTag = $oldRTag unless (defined $rTag);
    }
    if (defined $rTag) {
	$w->Select($rTag);
	$w->See($rTag);
    }
}

#----------------------------------------------------------------------
#		Accelerator key bindings
#----------------------------------------------------------------------
# tkIconList_KeyPress --
#
#	Gets called when user enters an arbitrary key in the listbox.
#
sub KeyPress {
    my($w, $key) = @_;
    $w->{'_ILAccel'} .= $key;
    $w->Goto($w->{'_ILAccel'});
    eval {
	$w->afterCancel($w->{'_ILAccel_afterid'});
    };
    $w->{'_ILAccel_afterid'} = $w->after(500, ['Reset', $w]);
}

sub Goto {
    my($w, $text) = @_;
    return unless (exists $w->{'list'});
    return if (not defined $text or $text eq '');
    my $start = (!exists $w->{'curItem'} ? 0 : $w->{'curItem'});
    $text = lc($text);
    my $theIndex = -1;
    my $less = 0;
    my $len = length($text);
    my $i = $start;
    # Search forward until we find a filename whose prefix is an exact match
    # with $text
    while (1) {
	my $sub = substr($w->{'textList'}{$i}, 0, $len);
	if ($text eq $sub) {
	    $theIndex = $i;
	    last;
	}
	++$i;
	$i = 0 if ($i == $w->{'numItems'});
	last if ($i == $start);
    }
    if ($theIndex > -1) {
	my $rTag = $w->{'list'}[$theIndex][2];
	$w->Select($rTag, 0);
	$w->See($rTag);
    }
}

sub Reset {
    my $w = shift;
    undef $w->{'_ILAccel'};
}

1;
