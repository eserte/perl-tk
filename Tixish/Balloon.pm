#
# The help widget that provides both "balloon" and "status bar"
# types of help messages.

package Tk::Balloon;

use vars qw($VERSION);
$VERSION = '3.016'; # $Id: //depot/Tk8/Tixish/Balloon.pm#16$

use Tk qw(Ev Exists);
use Carp;
require Tk::Toplevel;

Tk::Widget->Construct("Balloon");
@Tk::Balloon::ISA = qw(Tk::Toplevel);

use strict;

my @balloons;

sub ClassInit {
    my ($class, $mw) = @_;
    $mw->bind("all", "<Motion>", ['Tk::Balloon::Motion', Ev('X'), Ev('Y'), Ev('s')]);
    $mw->bind("all", "<Leave>",  ['Tk::Balloon::Motion', Ev('X'), Ev('Y'), Ev('s')]);
    $mw->bind("all", "<Button>", 'Tk::Balloon::ButtonDown');
    return $class;
}

sub Populate {
    my ($w, $args) = @_;

    $w->SUPER::Populate($args);

    $w->overrideredirect(1);
    $w->withdraw;
    # Only the container frame's background should be black... makes it
    # look better.
    $w->configure(-background => "black");
    my $a = $w->Frame;
    my $m = $w->Frame;
    $a->configure(-bd => 0);
    my $al = $a->Label(-bd => 0,
		       -relief => "flat",
		       -bitmap => '@' . Tk->findINC("balArrow.xbm"));
    $al->pack(-side => "left", -padx => 1, -pady => 1, -anchor => "nw");
    $m->configure(-bd => 0);
    my $ml = $m->Label(-bd => 0,
		       -padx => 0,
		       -pady => 0,
		       -text => $args->{-message});
    $w->Advertise("message" => $ml);
    $ml->pack(-side => "left",
	      -anchor => "w",
	      -expand => 1,
	      -fill => "both",
	      -padx => 10,
	      -pady => 3);
    $a->pack(-fill => "both", -side => "left");
    $m->pack(-fill => "both", -side => "left");

    # append to global list of balloons
    push(@balloons, $w);
    $w->{"popped"} = 0;
    $w->{"buttonDown"} = 0;
    $w->{"menu_index"} = 'none';
    $w->ConfigSpecs(-installcolormap => ["PASSIVE", "installColormap", "InstallColormap", 0],
		    -initwait => ["PASSIVE", "initWait", "InitWait", 350],
		    -state => ["PASSIVE", "state", "State", "both"],
		    -statusbar => ["PASSIVE", "statusBar", "StatusBar", undef],
		    -postcommand => ["PASSIVE", "postCommand", "PostCommand", undef],
		    -followmouse => ["PASSIVE", "followMouse", "FollowMouse", 0],
		    -show => ["PASSIVE", "show", "Show", 1],
		    -background => ["DESCENDANTS", "background", "Background", "#C0C080"],
		    -font => [$ml, "font", "Font", "-*-helvetica-medium-r-normal--*-120-*-*-*-*-*-*"],
		    -borderwidth => ["SELF", "borderWidth", "BorderWidth", 1]
);

}

# attach a client to the balloon
sub attach {
    my ($w, $client, %args) = @_;
    my $msg = delete $args{-msg};
    my $balloonmsg = delete $args{-balloonmsg};
    my $statusmsg = delete $args{-statusmsg};
    $balloonmsg = $msg if (not defined $balloonmsg);
    $statusmsg = $msg if (not defined $statusmsg);
    $w->{"clients"}->{$client} = {-balloonmsg => $balloonmsg, -statusmsg => $statusmsg};
    $client->OnDestroy([$w, 'detach', $client]);
}

# detach a client from the balloon.
sub detach 
{
    my ($w, $client) = @_;
    return unless Exists($w);
    $w->Deactivate if ($w->{"clients"} == $client);
    delete $w->{"clients"}->{$client};
}

sub Motion {
    my ($ewin, $x, $y, $s) = @_;

    # Don't do anything if a button is down or a grab is active
    # 0x1f00 is (Button1Mask | .. | Button5Mask)
    return if !defined $ewin || ((($s & 0x1f00) || $ewin->grabCurrent()) and $ewin->name ne 'menu');

    # Find which window we are over
    my $over = $ewin->Containing($x, $y);
    my ($w, $i);

    foreach $w (@balloons) {
	next if (($w->cget(-state) eq "none"));	# popping up disabled

	# if cursor has moved over the balloon -- ignore
	next if ((defined $over) && $over->toplevel eq $w);
	
	# Deactivate it if the followmouse flag is set:
	my $deactivate = $w->cget(-followmouse);
	
	# find the client window that matches
	my $client = $over;
	while (defined $client) {
	    last if (exists $w->{"clients"}->{$client});
	    $client = $client->Parent;
	}
	
	if (defined $client) {
	    if ($client->name eq 'menu') {
	        $i = $client->index('active');
		if ($w->{"menu_index"} ne $i and $w->{"popped"}) {
		    $deactivate = 1;
		} else {
		    $deactivate = 0;
		}
	    }
	    if ($deactivate or not $client->IS($w->{"client"})) {
		$w->Deactivate;
		$w->{"client"} = $client;
		$w->{"delay"}  = $client->after($w->cget(-initwait), sub {$w->SwitchToClient($client);});
	    }
	} 
	else {
	    # cursor is at a position covered by a non client
	    # pop down the balloon if it is up or scheduled.
	    $w->Deactivate if ($w->{"popped"} || $w->{"delay"});
	    $w->{"client"} = undef;
	    $w->{"menu_index"} = 'none';
	}
    }
}

sub ButtonDown {
    my ($ewin) = @_;
    my $w;
    foreach $w (@balloons) {
	$w->Deactivate if ($w->{"popped"} || $w->{"delay"});
    }
}

# switch the balloon to a new client
sub SwitchToClient {
    my ($w, $client) = @_;
    return unless Exists($w);
    return unless Exists($client);
    return unless $client->IS($w->{"client"});
    return if ($w->grabCurrent) and ($client->name ne 'menu');
    my $command = $w->cget(-postcommand);
    if (defined $command) {
	croak "$command is not a code reference" if ref $command ne 'CODE';
	&$command;
    }
    return if not $w->cget(-show);  # popping up has been canceled, probably by the postcommand.
    my $state = $w->cget(-state);
    $w->Popup if ($state =~ /both|balloon/);
    $w->SetStatus if ($state =~ /both|status/);
    $w->{"popped"} = 1;
    $w->{"delay"}  = $w->repeat(200, ['Verify', $w, $client]);
}

sub Verify {
    my ($w, $client) = @_;
    if ($client->name eq 'menu') {
	# We have to be a little more careful about verifying menu balloons:
	my $over = $client->Containing($client->pointerxy);
	return if not defined $over or $over->toplevel eq $w;
	my $i = $client->index('active');
	my $deactivate;
	if ($w->{"menu_index"} ne $i and $w->{"popped"}) {
	    $deactivate = 1;
	} else {
	    $deactivate = 0;
	}
	if ($deactivate or not $client->IS($w->{"client"})) {
	    $w->Deactivate;
	    $w->{"client"} = $client;
	    $w->{"delay"}  = $client->after($w->cget(-initwait), sub {$w->SwitchToClient($client);});
	}
    } else {
	$w->Deactivate if ($w->grabCurrent);
    }
}

sub Deactivate {
    my ($w) = @_;
    my $delay = delete $w->{"delay"};
    $delay->cancel if defined $delay;
    if ($w->{"popped"}) {
	$w->withdraw;
	$w->ClearStatus;
	$w->{"popped"} = 0;
	$w->{"menu_index"} = 'none';
    } else {
	$w->{"client"} = undef;
    }
}

sub Popup {
    my ($w) = @_;
    if ($w->cget(-installcolormap)) {
	$w->colormapwindows($w->winfo("toplevel"))
    }
    my $client = $w->{"client"};
    return if ((not defined $client) ||
	       (not exists $w->{"clients"}->{$client}));
    my $msg;
    if ($client->name eq 'menu') {
	my $i = $client->index('active');
	$w->{"menu_index"} = $i;
	return if $i eq 'none';
	croak "'".$w->{"clients"}->{$client}->{-balloonmsg}."' is not an array reference"
	  if ref $w->{"clients"}->{$client}->{-balloonmsg} ne 'ARRAY';
	$msg = (@{$w->{"clients"}->{$client}->{-balloonmsg}})[$i] || '';
    } else {
	$msg = $w->{"clients"}->{$client}->{-balloonmsg};
    }

    # Dereference it if it looks like a scalar reference:
    $msg = $$msg if ref $msg eq 'SCALAR';

    $w->Subwidget("message")->configure(-text => $msg);
    $w->idletasks;

    return unless Exists($w);
    return unless Exists($client);
    return if $msg eq '';  # Don't popup empty balloons.

    my ($x, $y);
    if ($w->cget(-followmouse) or $client->name eq 'menu') {
	$x = int($client->pointerx + 10);
	$y = int($client->pointery + 10);
    } else {
	$x = int($client->rootx + $client->width/2);
	$y = int($client->rooty + int ($client->height/1.3));
    }
    $w->geometry("+$x+$y");
#   $w->MoveToplevelWindow($x,$y);
    $w->deiconify();
    $w->raise;
    #$w->update;  # This can cause confusion by processing more Motion events before this one has finished.
}

sub SetStatus {
    my ($w) = @_;
    my $s = $w->cget(-statusbar);
    if ((defined $s) && $s->winfo("exists")) {
	my $vref = $s->cget(-textvariable);
	my $client = $w->{"client"};
	return if ((not defined $client) ||
		   (not exists $w->{"clients"}->{$client}));
	my $msg;
	if ($client->name eq 'menu') {
	    my $i = $client->index('active');
	    $w->{"menu_index"} = $i;
	    return if $i eq 'none';
	    croak "'".$w->{"clients"}->{$client}->{-statusmsg}."' is not an array reference"
	      if ref $w->{"clients"}->{$client}->{-statusmsg} ne 'ARRAY';
	    $msg = (@{$w->{"clients"}->{$client}->{-statusmsg}})[$i] || '';
	} else {
	    $msg = $w->{"clients"}->{$client}->{-statusmsg} || '';
	}
	# Dereference it if it looks like a scalar reference:
	$msg = $$msg if ref $msg eq 'SCALAR';
	if (not defined $vref) {
	    eval { $s->configure(-text => $msg); };
	} else {
	    $$vref = $msg;
	}
    }
}

sub ClearStatus {
    my ($w) = @_;
    my $s = $w->cget(-statusbar);
    if (defined $s && $s->winfo("exists")) {
	my $vref = $s->cget(-textvariable);
	if (defined $vref) {
	    $$vref = "";
	} else {
	    eval { $s->configure(-text => ""); }
	}
    }
}

sub destroy {
    my ($w) = @_;
    @balloons = grep($w != $_, @balloons);
    $w->SUPER::destroy;
}

1;

__END__

=cut
