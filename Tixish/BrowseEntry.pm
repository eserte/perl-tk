# $Id: BrowseEntry.pm,v 1.4 1997/02/08 19:19:35 rsi Exp $
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
    $e->configure(-textvariable => $w->{-variable});

    # popup shell for listbox with values.
    my $c = $w->Toplevel(-bd => 2, -relief => "raised");
    $c->overrideredirect(1);
    $c->withdraw;
    my $sl = $c->ScrlListbox(-selectmode => "browse");
    $w->Advertise("choices" => $c);
    $w->Advertise("slistbox" => $sl);
    $sl->pack(-expand => 1, -fill => "both");

    # other initializations
    $w->SetBindings;
    $w->{"popped"} = 0;
    $w->Delegates('insert' => $sl, 'delete' => $sl, DEFAULT => $e);
    $w->ConfigSpecs(-listwidth => ["PASSIVE", "listWidth", "ListWidth", undef],
		    -listcmd => ["PASSIVE", "listCmd", "ListCmd", undef],
		    -browsecmd => ["PASSIVE", "browseCmd", "BrowseCmd", undef],
		    "DEFAULT" => [$e]);
}

sub SetBindings {
    my ($w) = @_;

    my $e = $w->Subwidget("entry");
    my $b = $w->Subwidget("arrow");

    # set bind tags
    $w->bindtags([$w, 'Tk::BrowseEntry', $w->toplevel, "all"]);
    $e->bindtags([$e, $e->toplevel, "all"]);

    # bindings for the button and entry
    $b->bind("<1>", sub {$w->BtnDown;});
    $b->toplevel->bind("<ButtonRelease-1>", sub {$w->ButtonHack;});

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
	my $listcmd = $w->cget(-listcmd);
	if (defined $listcmd) {
	    &$listcmd($w);
	}
	my $e = $w->Subwidget("entry");
	my $c = $w->Subwidget("choices");
	my $s = $w->Subwidget("slistbox");
	my $a = $w->Subwidget("arrow");
	my $y1 = $e->rooty + $e->height + 3;
	my $bd = $c->cget(-bd) + $c->cget(-highlightthickness);
	my $ht = $s->reqheight + 2 * $bd;
	my $x1 = $e->rootx;
	my ($width, $x2);
	if (defined $w->cget(-listwidth)) {
	    $width = $w->cget(-listwidth);
	    $x2 = $x1 + $width;
	} else {
	    $x2 = $a->rootx + $a->width;
	    $width = $x2 - $x1;
	}
	my $rw = $c->reqwidth;
	if ($rw < $width) {
	    $rw = $width
	} else {
	    if ($rw > $width * 3) {
		$rw = $width * 3;
	    }
	    if ($rw > $w->vrootwidth) {
		$rw = $w->vrootwidth;
	    }
	}
	$width = $rw;
	
	# if listbox is too far right, pull it back to the left
	#
	if ($x2 > $w->vrootwidth) {
	    $x1 = $w->vrootwidth - $width;
	}

	# if listbox is too far left, pull it back to the right
	#
	if ($x1 < 0) {
	    $x1 = 0;
	}

	# if listbox is below bottom of screen, pull it up.
	my $y2 = $y1 + $ht;
	if ($y2 > $w->vrootheight) {
	    $y1 = $y1 - $ht - ($e->height - 5);
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
    if ((($x < 0) || ($x > $l->Width)) ||
	(($y < 0) || ($y > $l->Height))) {
	# mouse was clicked outside the listbox... close the listbox
	$w->LbClose;
    } else {
	# select appropriate entry and close the listbox
	$w->LbCopySelection;
	my $browsecmd = $w->cget(-browsecmd);
	if (defined $browsecmd) {
	    &$browsecmd($w, $w->Subwidget('entry')->get());
	}
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

# This hack is to prevent the ugliness of the arrow being depressed.
#
sub ButtonHack {
    my ($w) = @_;
    my $b = $w->Subwidget("arrow");
    if ($w->{"buttonHack"}) {
	$b->butUp;
    }
}

1;

__END__

=head1 NAME

Tk::BrowseEntry - entry widget with popup choices.

=head1 SYNOPSIS

    use Tk::BrowseEntry;

    $b = $frame->BrowseEntry(-label => "Label", -variable => \$var);
    $b->insert("end", "opt1");
    $b->insert("end", "opt2");
    $b->insert("end", "opt3");
    ...
    $b->pack;

=head1 DESCRIPTION

BrowseEntry is a poor man's ComboBox. It may be considered an
enhanced version of LabEntry which provides a button to popup the
choices of the possible values that the Entry may
take. BrowseEntry supports all the options LabEntry supports
except B<-textvariable>. This is replaced by B<-variable>. Other
options that BrowseEntry supports.

=over 4

=item B<-listwidth>

Specifies the width of the popup listbox.

=item B<-variable>

Specifies the variable in which the entered value is to be stored.

=item B<-browsecmd>

Specifies a function to call when a selection is made in the
popped up listbox. It is passed the widget and the text of the
entry selected. This function is called after the entry variable
has been assigned the value.

=item B<-listcmd>

Specifies the function to call when the button next to the entry
is pressed to popup the choices in the listbox. This is called before
popping up the listbox, so can be used to populate the entries in
the listbox.

=back

=head1 METHODS

=over 4

=item B<insert(>I<index>, I<string>B<)>

Inserts the text of I<string> at the specified I<index>. This string
then becomes available as one of the choices.

=item B<delete(>I<index1>, I<index2>B<)>

Deletes items from I<index1> to I<index2>.

=back

=head1 BUGS

BrowseEntry should really provide more of the ComboBox options.

=head1 AUTHOR

B<Rajappa Iyer> rsi@earthling.net

This code was inspired by ComboBox.tcl in Tix4.0 by Ioi Lam and
bears more than a passing resemblance to ComboBox code. This may
be distributed under the same conditions as Perl.
