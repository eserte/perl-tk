#
# BrowseEntry is a stripped down version of ComboBox.tcl from Tix4.0

package Tk::BrowseEntry;

use vars qw($VERSION);
$VERSION = '3.010'; # $Id: //depot/Tk8/Tixish/BrowseEntry.pm#10$

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
    my $lpack = delete $args->{-labelPack};
    if (not defined $lpack) {
	$lpack = [-side => "left", -anchor => "e"];
    }
    my $e = $w->LabEntry(-labelPack => $lpack);
    delete $args->{-label};
    my $b = $w->Button(-bitmap => '@' . Tk->findINC("cbxarrow.xbm"));
    $w->Advertise("entry" => $e);
    $w->Advertise("arrow" => $b);
    $b->pack(-side => "right", -padx => 1);
    $e->pack(-side => "right", -fill => 'x', -expand => 1, -padx => 1);

    # popup shell for listbox with values.
    my $c = $w->Toplevel(-bd => 2, -relief => "raised");
    $c->overrideredirect(1);
    $c->withdraw;
    my $sl = $c->Scrolled( qw/Listbox -selectmode browse -scrollbars oe/ );
    $w->Advertise("choices" => $c);
    $w->Advertise("slistbox" => $sl);
    $sl->pack(-expand => 1, -fill => "both");

    # other initializations
    $w->SetBindings;
    $w->{"popped"} = 0;
    $w->Delegates('insert' => $sl, 'delete' => $sl, get => $sl, DEFAULT => $e);
    $w->ConfigSpecs(
        -listwidth   => [qw/PASSIVE  listWidth   ListWidth/,   undef],
        -listcmd     => [qw/CALLBACK listCmd     ListCmd/,     undef],
        -browsecmd   => [qw/CALLBACK browseCmd   BrowseCmd/,   undef],
        -choices     => [qw/METHOD   choices     Choices/,     undef],
        -state       => [qw/METHOD   state       State         normal/],
        -arrowimage  => [ {-image => $b}, qw/arrowImage ArrowImage/, undef],
        -variable    => "-textvariable",
        DEFAULT      => [$e] );
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
    return if $w->cget( "-state" ) eq "disabled";

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
        my $var_ref = $w->cget( "-textvariable" );
        $$var_ref = $l->get($index);
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

sub choices {
    my $w = shift;
    unless( @_ ) {
        return( $w->get( qw/0 end/ ) );
    } else {
        my $choices = shift;
        if( $choices ) {
            $w->delete( qw/0 end/ );
            $w->insert( "end", @$choices );
        }
        return( "" );
    }
}

sub _set_edit_state {
    my( $w, $state ) = @_;
    
    my $entry  = $w->Subwidget( "entry" );
    my $button = $w->Subwidget( "arrow" );

    my $color;
    if( $state eq "normal" ) {                  # Editable
        $color = "gray95";
    } else {                                    # Not Editable
        $color = $w->cget( -background ) || "lightgray";
    }
    $entry->Subwidget( "entry" )->configure( -background => $color );

    if( $state eq "readonly" ) {
        $entry->configure( -state => "disabled" );
        $button->configure( -state => "normal" );
    } else {
        $entry->configure( -state => $state );
        $button->configure( -state => $state );
    }        
}

sub state {
    my $w = shift;
    unless( @_ ) {
        return( $w->{Configure}{-state} );
    } else {
        my $state = shift;
        $w->{Configure}{-state} = $state;
        $w->_set_edit_state( $state );
    }
}

sub _max {
    my $max = shift;
    foreach my $val (@_) {
        $max = $val if $max < $val;
    }
    return( $max );
}

sub shrinkwrap {
    my( $w, $size ) = @_;

    unless( defined $size ) {
        $size = _max( map( length, $w->get( qw/0 end/ ) ) ) || 0;;
    }

    my $lb = $w->Subwidget( "slistbox" )->Subwidget( "listbox" );
    $w->configure(  -width => $size );
    $lb->configure( -width => $size );
}


1;

__END__

