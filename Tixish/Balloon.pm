#
# The help widget that provides both "balloon" and "status bar"
# types of help messages.

package Tk::Balloon;

use vars qw($VERSION);
$VERSION = '3.024'; # $Id: //depot/Tk8/Tixish/Balloon.pm#24$

use Tk qw(Ev Exists);
use Carp;
require Tk::Toplevel;

Tk::Widget->Construct('Balloon');
use base qw(Tk::Toplevel);

use UNIVERSAL;

use strict;

my @balloons;
my $button_up = 0;

sub ClassInit {
    my ($class, $mw) = @_;
    $mw->bind('all', '<Motion>', ['Tk::Balloon::Motion', Ev('X'), Ev('Y'), Ev('s')]);
    $mw->bind('all', '<Leave>',  ['Tk::Balloon::Motion', Ev('X'), Ev('Y'), Ev('s')]);
    $mw->bind('all', '<Button>', 'Tk::Balloon::ButtonDown');
    $mw->bind('all', '<ButtonRelease>', 'Tk::Balloon::ButtonUp');
    return $class;
}

sub Populate {
    my ($w, $args) = @_;

    $w->SUPER::Populate($args);

    $w->overrideredirect(1);
    $w->withdraw;
    # Only the container frame's background should be black... makes it
    # look better.
    $w->configure(-background => 'black');
    my $a = $w->Frame;
    my $m = $w->Frame;
    $a->configure(-bd => 0);
    my $al = $a->Label(-bd => 0,
		       -relief => 'flat',
		       -bitmap => '@' . Tk->findINC('balArrow.xbm'));
    $al->pack(-side => 'left', -padx => 1, -pady => 1, -anchor => 'nw');
    $m->configure(-bd => 0);
    my $ml = $m->Label(-bd => 0,
		       -padx => 0,
		       -pady => 0,
		       -text => $args->{-message});
    $w->Advertise('message' => $ml);
    $ml->pack(-side => 'left',
	      -anchor => 'w',
	      -expand => 1,
	      -fill => 'both',
	      -padx => 10,
	      -pady => 3);
    $a->pack(-fill => 'both', -side => 'left');
    $m->pack(-fill => 'both', -side => 'left');

    # append to global list of balloons
    push(@balloons, $w);
    $w->{'popped'} = 0;
    $w->{'buttonDown'} = 0;
    $w->{'menu_index'} = 'none';
    $w->{'menu_index_over'} = 'none';
    $w->{'canvas_tag'} = '';
    $w->{'canvas_tag_over'} = '';
    $w->ConfigSpecs(-installcolormap => ['PASSIVE', 'installColormap', 'InstallColormap', 0],
		    -initwait => ['PASSIVE', 'initWait', 'InitWait', 350],
		    -state => ['PASSIVE', 'state', 'State', 'both'],
		    -statusbar => ['PASSIVE', 'statusBar', 'StatusBar', undef],
		    -balloonposition => ['PASSIVE', 'balloonPosition', 'BalloonPosition', 'widget'],
		    -postcommand => ['PASSIVE', 'postCommand', 'PostCommand', undef],
		    -cancelcommand => ['PASSIVE', 'cancelCommand', 'CancelCommand', undef],
		    -motioncommand => ['PASSIVE', 'motionCommand', 'MotionCommand', undef],
		    -background => ['DESCENDANTS', 'background', 'Background', '#C0C080'],
		    -font => [$ml, 'font', 'Font', '-*-helvetica-medium-r-normal--*-120-*-*-*-*-*-*'],
		    -borderwidth => ['SELF', 'borderWidth', 'BorderWidth', 1]
		   );

}

# attach a client to the balloon
sub attach {
    my ($w, $client, %args) = @_;
    my $msg = delete $args{-msg};
    $args{-balloonmsg} = $msg unless exists $args{-balloonmsg};
    $args{-statusmsg}  = $msg unless exists $args{-statusmsg};
    $w->{'clients'}{$client} = \%args;
    $client->OnDestroy([$w, 'detach', $client]);
}

# detach a client from the balloon.
sub detach {
    my ($w, $client) = @_;
    return unless Exists($w);
    $w->Deactivate if ($w->{'clients'} == $client);
    delete $w->{'clients'}{$client};
}

sub Motion {
    my ($ewin, $x, $y, $s) = @_;

    # Don't do anything if a button is down or a grab is active
    # 0x1f00 is (Button1Mask | .. | Button5Mask)
    return if not defined $ewin or ((($s & 0x1f00) or $ewin->grabCurrent()) and not $ewin->isa('Tk::Menu'));

    # Find which window we are over
    my $over = $ewin->Containing($x, $y);

    foreach my $w (@balloons) {
	# if cursor has moved over the balloon -- ignore
	next if defined $over and $over->toplevel eq $w;

	# find the client window that matches
	my $client = $over;
	while (defined $client) {
	    last if (exists $w->{'clients'}{$client});
	    $client = $client->Parent;
	}

	if (defined $client) {
	    # popping up disabled -- ignore
	    my $state = (exists $w->{'clients'}{$client}{-state}
			 ? $w->{'clients'}{$client}{-state}
			 : $w->cget(-state));
	    next if $state eq 'none';

	    # Check if a button was recently released:
	    my $deactivate = 0;
	    if ($button_up) {
	      $deactivate = 1;
	      $button_up = 0;
	    }
	    # Deactivate it if the motioncommand says to:
	    my $command = (exists $w->{'clients'}{$client}{-motioncommand}
			   ? $w->{'clients'}{$client}{-motioncommand}
			   : $w->cget(-motioncommand));
	    if (defined $command) {
		croak "$command is not a code reference" if not UNIVERSAL::isa($command, 'CODE');
		$deactivate = &$command;
	    }

	    if ($client->isa('Tk::Menu') and
		(UNIVERSAL::isa($w->{'clients'}{$client}{-balloonmsg}, 'ARRAY') or
		 UNIVERSAL::isa($w->{'clients'}{$client}{-statusmsg}, 'ARRAY'))) {
	        my $i = $client->index('active');
		if ($i eq 'none' and $client->IS($w->{'client'})) {
		    my $y = $client->pointery - $client->rooty;
		    $i = $client->index("\@$y");
		}
		$deactivate = $deactivate || ($w->{'menu_index_over'} ne $i);
		$w->{'menu_index_over'} = $i;
	    } elsif ($client->isa('Tk::Canvas') and
		     (UNIVERSAL::isa($w->{'clients'}{$client}{-balloonmsg}, 'HASH') or
		      UNIVERSAL::isa($w->{'clients'}{$client}{-statusmsg}, 'HASH'))) {
		my @tags = ($client->find('withtag', 'current'),
			    $client->gettags('current'), '');
		$w->{'canvas_tag'} = '' if not defined $w->{'canvas_tag'};
		$deactivate = $deactivate || ($tags[0] ne $w->{'canvas_tag_over'});
		$w->{'canvas_tag_over'} = $tags[0];
	    }
	    if ($deactivate or not $client->IS($w->{'client'})) {
		my $initwait = (exists $w->{'clients'}{$client}{-initwait}
				? $w->{'clients'}{$client}{-initwait}
				: $w->cget(-initwait));
		$w->Deactivate;
		$w->{'client'} = $client;
		$w->{'delay'}  = $client->after($initwait,
						sub {$w->SwitchToClient($client);});
	    }
	} else {
	    # cursor is at a position covered by a non client
	    # pop down the balloon if it is up or scheduled.
	    $w->Deactivate;
	    $w->{'client'} = undef;
	    $w->{'menu_index'} = 'none';
	    $w->{'canvas_tag'} = '';
	}
    }
}

sub ButtonDown {
    my ($ewin) = @_;

    foreach my $w (@balloons) {
	$w->Deactivate;
    }
}

sub ButtonUp {
    $button_up = 1;
}

# switch the balloon to a new client
sub SwitchToClient {
    my ($w, $client) = @_;
    return unless Exists($w);
    return unless Exists($client);
    return unless $client->IS($w->{'client'});
    return if $w->grabCurrent and not $client->isa('Tk::Menu');
    my $command = (exists $w->{'clients'}{$client}{-postcommand}
		   ? $w->{'clients'}{$client}{-postcommand}
		   : $w->cget(-postcommand));
    if (defined $command) {
	croak "$command is not a code reference" if not UNIVERSAL::isa($command, 'CODE');
	# Execute the user's command and return if it returns false:
	my $pos = &$command;
	return if not $pos;
	if ($pos =~ /^(\d+),(\d+)$/) {
	    # Save the returned position so the Popup method can use it:
	    $w->{'clients'}{$client}{'postposition'} = [$1, $2];
	}
    }
    my $state = (exists $w->{'clients'}{$client}{-state}
		 ? $w->{'clients'}{$client}{-state}
		 : $w->cget(-state));
    $w->Popup if ($state =~ /both|balloon/);
    $w->SetStatus if ($state =~ /both|status/);
    $w->{'popped'} = 1;
    $w->{'delay'}  = $w->repeat(200, ['Verify', $w, $client]);
}

sub Verify {
    my ($w, $client) = @_;
    my $over = $client->Containing($client->pointerxy);
    return if not defined $over or $over->toplevel eq $w;
    my $deactivate = 0;
    if ($client->isa('Tk::Menu')) {
	# We have to be a little more careful about verifying menu balloons:
	if (UNIVERSAL::isa($w->{'clients'}{$client}{-balloonmsg}, 'ARRAY') or
	    UNIVERSAL::isa($w->{'clients'}{$client}{-statusmsg}, 'ARRAY')) {
	    my $i = $client->index('active');
	    if ($i eq 'none' and $over eq $client) {
		my $y = $client->pointery - $client->rooty;
		$i = $client->index("\@$y");
	    }
	    $deactivate = ($w->{'menu_index'} ne $i);
	} elsif ($over ne $client) {
	    $deactivate = 1;
	}
    } elsif ($client->isa('Tk::Canvas')) {
	if (UNIVERSAL::isa($w->{'clients'}{$client}{-balloonmsg}, 'HASH') or
	    UNIVERSAL::isa($w->{'clients'}{$client}{-statusmsg}, 'HASH')) {
	    my @tags = ($client->find('withtag', 'current'),
			$client->gettags('current'), '');
	    $w->{'canvas_tag'} = '' if not defined $w->{'canvas_tag'};
	    $deactivate = ($tags[0] ne $w->{'canvas_tag'});
	}
    } elsif ($w->grabCurrent) {
	$deactivate = 1;
    }

    if ($deactivate or not $client->IS($w->{'client'})) {
	$w->Deactivate;
    }
}

sub Deactivate {
    my ($w) = @_;
    my $delay = delete $w->{'delay'};
    $delay->cancel if defined $delay;
    if ($w->{'popped'}) {
	my $client = $w->{'client'};
	my $command = (exists $w->{'clients'}{$client}{-cancelcommand}
		       ? $w->{'clients'}{$client}{-cancelcommand}
		       : $w->cget(-cancelcommand));
	if (defined $command) {
	    croak "$command is not a code reference" if not UNIVERSAL::isa($command, 'CODE');
	    # Execute the user's command and return if it returns false:
	    return if not &$command;
	}
	$w->withdraw;
	$w->ClearStatus;
	$w->{'popped'} = 0;
	$w->{'menu_index'} = 'none';
	$w->{'canvas_tag'} = '';
    }
    $w->{'client'} = undef;
}

sub Popup {
    my ($w) = @_;
    if ($w->cget(-installcolormap)) {
	$w->colormapwindows($w->winfo('toplevel'))
    }
    my $client = $w->{'client'};
    return if not defined $client or not exists $w->{'clients'}{$client};
    my $msg;
    if ($client->isa('Tk::Menu') and
	UNIVERSAL::isa($w->{'clients'}{$client}{-balloonmsg}, 'ARRAY')) {
	my $i = $client->index('active');
	if ($i eq 'none' and $client->IS($w->{'client'})) {
	    my $y = $client->pointery - $client->rooty;
	    $i = $client->index("\@$y");
	}
	$w->{'menu_index'} = $i;
	return if $i eq 'none';
	$msg = (@{$w->{'clients'}{$client}{-balloonmsg}})[$i] || '';
    } elsif ($client->isa('Tk::Canvas') and
	     UNIVERSAL::isa($w->{'clients'}{$client}{-balloonmsg}, 'HASH')) {
	my @tags = ($client->find('withtag', 'current'),
		    $client->gettags('current'));
	$w->{'canvas_tag'} = $tags[0];
	$msg = '';
	foreach (@tags) {
	    if (exists $w->{'clients'}{$client}{-balloonmsg}{$_}) {
		$msg = $w->{'clients'}{$client}{-balloonmsg}{$_};
		last;
	    }
	}
    } else {
	$msg = $w->{'clients'}{$client}{-balloonmsg};
    }

    # Dereference it if it looks like a scalar reference:
    $msg = $$msg if UNIVERSAL::isa($msg, 'SCALAR');

    $w->Subwidget('message')->configure(-text => $msg);
    $w->idletasks;

    return unless Exists($w);
    return unless Exists($client);
    return if $msg eq '';  # Don't popup empty balloons.

    my ($x, $y);
    my $pos = (exists $w->{'clients'}{$client}{-balloonposition}
	       ? $w->{'clients'}{$client}{-balloonposition}
	       : $w->cget(-balloonposition));
    my $postpos = delete $w->{'clients'}{$client}{'postposition'};
    if (defined $postpos) {
	# The postcommand must have returned a position for the balloon - I will use that:
	($x, $y) = @{$postpos};
    } elsif ($pos eq 'mouse') {
	$x = int($client->pointerx + 10);
	$y = int($client->pointery + 10);
    } elsif ($pos eq 'widget') {
	$x = int($client->rootx + $client->width/2);
	$y = int($client->rooty + int ($client->height/1.3));
    } else {
	croak "'$pos' is not a valid position for the balloon - it must be one of: 'widget', 'mouse'.";
    }
    $w->geometry("+$x+$y");
    #$w->MoveToplevelWindow($x,$y);
    $w->deiconify();
    $w->raise;
    #$w->update;  # This can cause confusion by processing more Motion events before this one has finished.
}

sub SetStatus {
    my ($w) = @_;
    my $client = $w->{'client'};
    my $s = (exists $w->{'clients'}{$client}{-statusbar}
	     ? $w->{'clients'}{$client}{-statusbar}
	     : $w->cget(-statusbar));
    if (defined $s and $s->winfo('exists')) {
	my $vref = $s->cget(-textvariable);
	return if not defined $client or not exists $w->{'clients'}{$client};
	my $msg;
	if ($client->isa('Tk::Menu') and
	    UNIVERSAL::isa($w->{'clients'}{$client}{-statusmsg}, 'ARRAY')) {
	    my $i = $client->index('active');
	    if ($i eq 'none' and $client->IS($w->{'client'})) {
		my $y = $client->pointery - $client->rooty;
		$i = $client->index("\@$y");
	    }
	    $w->{'menu_index'} = $i;
	    return if $i eq 'none';
	    $msg = (@{$w->{'clients'}{$client}{-statusmsg}})[$i] || '';
	} elsif ($client->isa('Tk::Canvas') and
		 UNIVERSAL::isa($w->{'clients'}{$client}{-statusmsg}, 'HASH')) {
	    my @tags = ($client->find('withtag', 'current'),
			$client->gettags('current'));
	    $w->{'canvas_tag'} = $tags[0];
	    $msg = '';
	    foreach (@tags) {
		if (exists $w->{'clients'}{$client}{-statusmsg}{$_}) {
		    $msg = $w->{'clients'}{$client}{-statusmsg}{$_};
		    last;
		}
	    }
	} else {
	    $msg = $w->{'clients'}{$client}{-statusmsg} || '';
	}
	# Dereference it if it looks like a scalar reference:
	$msg = $$msg if UNIVERSAL::isa($msg, 'SCALAR');
	if (not defined $vref) {
	    eval { $s->configure(-text => $msg); };
	} else {
	    $$vref = $msg;
	}
    }
}

sub ClearStatus {
    my ($w) = @_;
    my $client = $w->{'client'};
    my $s = (exists $w->{'clients'}{$client}{-statusbar}
	     ? $w->{'clients'}{$client}{-statusbar}
	     : $w->cget(-statusbar));
    if (defined $s and $s->winfo('exists')) {
	my $vref = $s->cget(-textvariable);
	if (defined $vref) {
	    $$vref = '';
	} else {
	    eval { $s->configure(-text => ''); }
	}
    }
}

sub destroy {
    my ($w) = @_;
    @balloons = grep($w != $_, @balloons);
    #$w->SUPER::destroy;
    # Above doesn't seem to work but at least I have removed it from the
    # list of balloons and maybe undef'ing the object will get rid of it.
    undef $w;
}

1;

