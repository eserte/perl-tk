# $Id: BrowseEntry.pm,v 1.2 1996/09/02 21:41:01 rsi Exp $
#
# BrowseEntry is a stripped down version of ComboBox.tcl from Tix4.0

package Tk::BrowseEntry;

use Tk;
use Carp;
use strict;

require Tk::Frame;
require Tk::LabEntry;

Tk::Widget->Construct("BrowseEntry");

@Tk::BrowseEntry::ISA = qw(Tk::Frame);

sub Populate {
    my ($w, $args) = @_;
    
    $w->SUPER::Populate($args);

    # entry widget and arrow button
    $w->{-variable} = delete $args->{-variable};
    my $lpack = delete $args->{-labelPack};
    if (not defined $lpack) {
	$lpack = [-side => "left", -anchor => "e"];
    }
    my $e = $w->LabEntry(-labelPack => $lpack, %$args);
    delete $args->{-label};
    my $b = $w->Button(-bitmap => '@' . Tk->findINC("cbxarrow.xbm"));
    $w->Advertise("entry" => $e);
    $w->Advertise("arrow" => $b);
    $b->pack(-side => "right", -padx => 1);
    $e->pack(-side => "right", -fill => 'x', -expand => 1, -padx => 1);
    $e->Subwidget("entry")->configure(-textvariable => $w->{-variable});

    # popup shell for listbox with values.
    my $c = $w->Toplevel(-bd => 2, -relief => "raised");
    $c->overrideredirect(1);
    $c->withdraw;
    my $sl = $c->ScrlListbox(-selectMode => "browse");
    $w->Advertise("choices" => $c);
    $w->Advertise("slistbox" => $sl);
    $sl->pack(-expand => 1, -fill => "both");

    # other initializations
    $w->SetBindings;
    $w->{"popped"} = 0;
    $w->ConfigSpecs(-listwidth => ["PASSIVE", "listWidth", "ListWidth", undef],
		    "DEFAULT" => [$e->Subwidget("entry")]);
}
sub SetBindings {
    my ($w) = @_;
    
    my $e = $w->Subwidget("entry");
    my $b = $w->Subwidget("arrow");
    
    # set bind tags
    $w->bindtags([$w, 'Tk::BrowseEntry', $w->winfo("toplevel"), "all"]);
    $e->bindtags([$e, $e->winfo("toplevel"), "all"]);
    
    # bindings for the button and entry
    $b->bind("<1>", sub {$w->BtnDown;});
    $b->winfo("toplevel")->bind("<ButtonRelease-1>", sub {$w->ButtonHack;});
    
    # bindings for listbox
    my $sl = $w->Subwidget("slistbox");
    my $l = $sl->Subwidget("listbox");
    $l->bind("<ButtonRelease-1>", sub {
	$w->ButtonHack;
	LbChoose($w, $l->XEvent->x, $l->XEvent->y);
    });
    
    # allow click outside the popped up listbox to pop it down.
    $w->bind("<1>", sub {$w->BtnDown;});
}

sub BtnDown {
    my ($w) = @_;
    if ($w->cget(-state) =~ /disabled/) {
	return;
    }
    if ($w->{"popped"}) {
	$w->Popdown;
	$w->{"buttonHack"} = 0;
    } else {
	$w->PopupChoices;
	$w->{"buttonHack"} = 1;
    }
}

sub PopupChoices {
    my ($w) = @_;
    
    if (!$w->{"popped"}) {
	my $e = $w->Subwidget("entry");
	my $c = $w->Subwidget("choices");
	my $s = $w->Subwidget("slistbox");
	my $a = $w->Subwidget("arrow");
	my $y1 = $e->winfo("rooty") + $e->winfo("height") + 3;
	my $bd = $c->cget(-bd) + $c->cget(-highlightthickness);
	my $ht = $s->winfo("reqheight") + 2 * $bd;
	my $x1 = $e->winfo("rootx");
	my ($width, $x2);
	if (defined $w->cget(-listwidth)) {
	    $width = $w->cget(-listwidth);
	    $x2 = $x1 + $width;
	} else {
	    $x2 = $a->winfo("rootx") + $a->winfo("width");
	    $width = $x2 - $x1;
	}
	my $rw = $c->winfo("reqwidth");
	if ($rw < $width) {
	    $rw = $width
	} else {
	    if ($rw > $width * 3) {
		$rw = $width * 3;
	    }
	    if ($rw > $w->winfo("vrootwidth")) {
		$rw = $w->winfo("vrootwidth");
	    }
	}
	$width = $rw;
	
	# if listbox is too far right, pull it back to the left
	#
	if ($x2 > $w->winfo("vrootwidth")) {
	    $x1 = $w->winfo("vrootwidth") - $width;
	}
    
	# if listbox is too far left, pull it back to the right
	#
	if ($x1 < 0) {
	    $x1 = 0;
	}

	# if listbox is below bottom of screen, pull it up.
	my $y2 = $y1 + $ht;
	if ($y2 > $w->winfo("vrootheight")) {
	    $y1 = $y1 - $ht - ($e->winfo("height") - 5);
	}

	$c->geometry(sprintf("%dx%d+%d+%d", $rw, $ht, $x1, $y1));
	$c->deiconify;
	$c->raise;
	$e->focus;
	$w->{"popped"} = 1;

	$c->configure(-cursor => "arrow");
	$w->grabGlobal;
    }
}

# choose value from listbox if appropriate
sub LbChoose {
    my ($w, $x, $y) = @_;
    my $l = $w->Subwidget("slistbox")->Subwidget("listbox");
    if ((($x < 0) || ($x > $l->winfo("width"))) ||
	(($y < 0) || ($y > $l->winfo("height")))) {
	# mouse was clicked outside the listbox... close the listbox
	$w->LbClose;
    } else {
	# select appropriate entry and close the listbox
	$w->LbCopySelection;
    }
}

# close the listbox after clearing selection
sub LbClose {
    my ($w) = @_;
    my $l = $w->Subwidget("slistbox")->Subwidget("listbox");
    $l->selection("clear", 0, "end");
    $w->Popdown;
}

# copy the selection to the entry and close listbox
sub LbCopySelection {
    my ($w) = @_;
    my $index = $w->LbIndex;
    if (defined $index) {
	$w->{"curIndex"} = $index;
	my $l = $w->Subwidget("slistbox")->Subwidget("listbox");
	${$w->{-variable}} = $l->get($index);
	if ($w->{"popped"}) {
	    $w->Popdown;
	}
    }
    $w->Popdown;
}

sub LbIndex {
    my ($w, $flag) = @_;
    my $sel = $w->Subwidget("slistbox")->Subwidget("listbox")->curselection;
    if (defined $sel) {
	return int($sel);
    } else {
	if (defined $flag && ($flag eq "emptyOK")) {
	    return undef;
	} else {
	    return 0;
	}
    }
}

# pop down the listbox
sub Popdown {
    my ($w) = @_;
    if ($w->{"popped"}) {
	my $c = $w->Subwidget("choices");
	$c->withdraw;
	$w->grabRelease;
	$w->{"popped"} = 0;
    }
}

sub insert {
    my ($w, $index, $newitem) = @_;
    my $l = $w->Subwidget("slistbox")->Subwidget("listbox");
    $l->insert($index, $newitem);
}

# This hack is to prevent the ugliness of the arrow being depressed.
#
sub ButtonHack {
    my ($w) = @_;
    my $b = $w->Subwidget("arrow");
    if ($w->{"buttonHack"}) {
	$b->butUp;
    }
}

#
# $Log: BrowseEntry.pm,v $
# Revision 1.2  1996/09/02 21:41:01  rsi
# Forced cursor to be arrow in the popped up listbox.
# Added bindings and code to ensure that if mouse is pressed
# outside popped up listbox, the listbox is closed.
#
# Revision 1.1  1996/08/29 21:45:13  rsi
# Initial revision


