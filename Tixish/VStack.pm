# $Id: //depot/Tk/Tixish/VStack.pm#7$
#
# Virtual base class needed to implement the NoteBook widget. This should
# not be used directly by the application programmer.
#
# Derived from VStack.tcl in Tix 4.0

package Tk::VStack;
require Tk::Frame;

use strict;
use Carp;

@Tk::VStack::ISA = qw(Tk::Frame);


use vars qw($VERSION);
$VERSION = '2.007'; # $Id: //depot/Tk/Tixish/VStack.pm#7$

sub Populate {
    my ($w, $args) = @_;

    $w->SUPER::Populate($args);
    $w->{"pad-x1"} = 0;
    $w->{"pad-x2"} = 0;
    $w->{"pad-y1"} = 0;
    $w->{"pad-y2"} = 0;

    $w->{"nWindows"} = 0;
    $w->{"minH"} = 1;
    $w->{"minW"} = 1;
    
    $w->{"top"} = $w;
    $w->{"counter"} = 0;
    $w->{"resize"} = 0;

    $w->ConfigSpecs(-ipadx => ["PASSIVE", "ipadX", "Pad", 0],
		    -ipady => ["PASSIVE", "ipadY", "Pad", 0],
		    -dynamicgeometry => ["PASSIVE", "dynamicGeometry", "DynamicGeometry", 0]);

    # SetBindings
    $w->bind("<Configure>", sub {$w->MasterGeomProc;});
    $w->{"top"}->bind("<Destroy>", sub {$w->DestroyTop;});

    $w->QueueResize;
}

sub add {
    my ($w, $child, %args) = @_;

    my $f = $w->Frame(Name => $child);
    $f->configure(-relief => "raised");
    $f->{-raisecmd} = $args{-raisecmd} if (defined $args{-raisecmd});
    $f->{-createcmd} = $args{-createcmd} if (defined $args{-createcmd});

    # manage our geometry
    $w->ManageGeometry($f);
    # create default bindings
    $f->bind("<Configure>", sub {$w->ClientGeomProc('-configure', $f)});
    $f->bind("<Destroy>", sub {$w->delete($child);}); # XXX
    $w->{$child} = $f;
    $w->{"nWindows"}++;
    push(@{$w->{"windows"}}, $child);
    
    return $f;
}

sub delete {
    my ($w, $child) = @_;

    if (defined $w->{$child}) {
	# see if the child to be deleted was the top child
	if ((defined $w->{"topchild"}) && ($w->{"topchild"} eq $child)) {
	    foreach (@{$w->{"windows"}}) {
		if ($_ !~ /$child/) {
		    $w->raise ( $_  );
		    $w->{"topchild"} = $_;
		    next;
		}
	    }
	}
	$w->{$child}->bind("<Destroy>", undef);
	$w->{$child}->destroy;
	
	@{$w->{"windows"}} = grep($_ !~ /$child/, @{$w->{"windows"}});
	# if $w->{'windows'} is empty then set topchild to null
	if ( $#{$w->{'windows'}} == -1 ) {
		$w->{'topchild'} = undef;
	}
	$w->{"nWindows"}--;
	delete $w->{$child};
    } else {
	carp "page $child does not exist";
    }
}

sub pagecget {
    my ($w, $child, $opt) = @_;

    if (defined $w->{$child}) {
	return $w->{$child}->{-createcmd} if ($opt =~ /-createcmd/);
	return $w->{$child}->{-raisecmd} if ($opt =~ /-raisecmd/);
	return $w->{"top"}->pagecget($child, $opt);
    } else {
	carp "page $child does not exist";
    }
}

sub pageconfigure {
    my ($w, $child, %args) = @_;

    if (defined $w->{$child}) {
	my $ccmd = delete $args{-createcmd};
	my $rcmd = delete $args{-raisecmd};
	$w->{-createcmd} = $ccmd if (defined $ccmd);
	$w->{-raisecmd} = $rcmd if (defined $rcmd);
	if (keys %args) {
	    $w->{"top"}->pageconfigure($child, %args);
	}
    }
}

sub pages {
    my ($w) = @_;

    return @{$w->{"windows"}};
}

sub raise {
    my ($w, $child) = @_;

    if (defined $w->{$child}) {
	if (defined $w->{$child}->{-createcmd}) {
	    &{$w->{$child}->{-createcmd}}($w->{$child});
	    delete $w->{$child}->{-createcmd};
	}
	# hide the original visible window
	if (defined $w->{"topchild"} && ($w->{"topchild"} ne $child)) {
	    $w->{$w->{"topchild"}}->UnmapWindow;
	}
	my $oldtop = $w->{"topchild"};
	$w->{"topchild"} = $child;
	my $myW = $w->winfo("width");
	my $myH = $w->winfo("height");

	my $cW = $myW - $w->{"pad-x1"} - $w->{"pad-x2"} - 2 * (defined $w->{-ipadx} ? $w->{-ipadx} : 0);
	my $cH = $myH - $w->{"pad-y1"} - $w->{"pad-y2"} - 2 * (defined $w->{-ipady} ? $w->{-ipady} : 0);
	my $cX = $w->{"pad-x1"} + (defined $w->{-ipadx} ? $w->{-ipadx} : 0);
	my $cY = $w->{"pad-y1"} + (defined $w->{-ipady} ? $w->{-ipady} : 0);

	if ($cW > 0 && $cH > 0) {
	    $w->{$child}->MoveResizeWindow($cX, $cY, $cW, $cH);
	    $w->{$child}->MapWindow;
	    $w->{$child}->raise;
	}
	if ((not defined $oldtop) || ($oldtop ne $child)) {
	    if (defined $w->{$child}->{-raisecmd}) {
		&{$w->{$child}->{-raisecmd}}($w->{$child});
	    }
	}
    }
}

sub raised {
    my ($w) = @_;
    return $w->{"topchild"};
}

# ------
# Private routines
# ------
sub DestroyTop {
    my ($w) = @_;
    eval { $w->destroy; }
}

sub MasterGeomProc {
    my ($w, %args) = @_;
    if ($w->winfo("exists")) {
	if (not defined $w->{"resize"}) {
	    $w->{"resize"} = 0;
	}
	$w->QueueResize;
    }
}

sub SlaveGeometryRequest {
    my $w = shift;
    if ($w->winfo("exists")) {
	$w->QueueResize;
    }
}

sub LostSlave {
    my ($w, $s) = @_;
    $s->UnmapWindow;
}

sub ClientGeomProc {
    my ($w, $flag, $client) = @_;

    if ($w->winfo("exists")) {
	$w->QueueResize;
    }
    if ($flag =~ /-lostslave/) {
	carp "Geometry Management Error: Another geometry manager has taken control of $client. This error is usually caused because a widget has been created in the wrong frame: it should have been created inside $client instead of $w";
	
    }
}

sub QueueResize {
    my $w = shift;
    $w->DoWhenIdle(['Resize', $w]) unless ($w->{"resize"}++);
}

sub Resize {
    my ($w) = @_;
    my $top;
    my $reqW = 0;
    my $reqH = 0;

    return if ((!$w->winfo("exists")) || (!$w->{"nWindows"}) || (!$w->{"resize"}));
    $w->{"resize"} = 0;
    $reqW = $w->{-width} if (defined $w->{-width});
    $reqH = $w->{-height} if (defined $w->{-height});

    if ($reqW * $reqH == 0) {
	if ((not defined $w->{-dynamicgeometry}) ||
	    ($w->{-dynamicgeometry} == 0)) {
	    my $child = '';
	    $reqW = 1;
	    $reqH = 1;
	    
	    foreach $child (@{$w->{"windows"}}) {
		my $cW = $w->{$child}->winfo("reqwidth");
		my $cH = $w->{$child}->winfo("reqheight");
		$reqW = ($reqW > $cW) ? $reqW : $cW;
		$reqH = ($reqH > $cH) ? $reqH : $cH;
	    }
	} else {
	    if (defined $w->{"topchild"}) {
		$reqW = $w->{"topchild"}->winfo("reqwidth");
		$reqH = $w->{"topchild"}->winfo("reqheight");
	    } else {
		$reqW = 1;
		$reqH = 1;
	    }
	}
	$reqW += $w->{"pad-x1"} + $w->{"pad-x2"} + 2 * (defined $w->{-ipadx} ? $w->{-ipadx} : 0);
	$reqH += $w->{"pad-y1"} + $w->{"pad-y2"} + 2 * (defined $w->{-ipady} ? $w->{-ipady} : 0);
	$reqW = ($reqW > $w->{"minW"}) ? $reqW : $w->{"minW"};
	$reqH = ($reqH > $w->{"minH"}) ? $reqH : $w->{"minH"};
    }
    if (($w->winfo("reqwidth") != $reqW) ||
	($w->winfo("reqheight") != $reqH)) {
	$w->{"counter"} = 0 if (not defined $w->{"counter"});
	if ($w->{"counter"} < 50) {
	    $w->{"counter"}++;
	    $w->GeometryRequest($reqW, $reqH);
	    $w->DoWhenIdle(sub {$w->Resize;});
	    $w->{"resize"} = 1;
	    return;
	}
    }
    $w->{"counter"} = 0;
    if ($w->{"top"} != $w) {
	$w->{"top"}->MoveResizeWindow(0, 0, $w->winfo("width"), $w->winfo("height"));
	$w->{"top"}->MapWindow;
    }
    if (not defined $w->{"topchild"}) {
	$top = ${$w->{"windows"}}[0];
    } else {
	$top = $w->{"topchild"};
    }
    $w->raise($top);
    $w->{"resize"} = 0;
}

1;

__END__
    
