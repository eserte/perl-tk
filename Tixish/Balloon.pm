#
# The help widget that provides both "balloon" and "status bar"
# types of help messages.

package Tk::Balloon;

use vars qw($VERSION);
$VERSION = '3.012'; # $Id: //depot/Tk8/Tixish/Balloon.pm#12$

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
    return if ($s || $ewin->grabCurrent()) and $ewin->name ne 'menu';

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

=head1 NAME

Tk::Balloon - pop up help balloons.

=for category Tix Extensions

=head1 SYNOPSIS

    use Tk::Balloon;
    ...
    $b = $top->Balloon(-statusbar => $status_bar_widget);

    # Normal Balloon:
    $b->attach($widget,
	       -balloonmsg => "Balloon help message",
	       -statusmsg => "Status bar message");

    # Balloon attached to a menu widget:
    $b->attach($file_menu->menu, -msg => ['first menu entry',
					  'second menu entry',
					  ...
					 ],
	      );

=head1 DESCRIPTION

B<Balloon> provides the framework to create and attach help
balloons to various widgets so that when the mouse pauses over the
widget for more than a specified amount of time, a help balloon is
popped up. If the balloon is attached to a menu widget then it
will expect the message arguments to be array references with
each element in the array corresponding to a menu entry. The balloon
message will then be shown for the active menu entry.

B<Balloon> accepts all of the options that the B<Frame> widget
accepts. In addition, the following options are also recognized.

=over 4

=item B<-initwait>

Specifies the amount of time to wait without activity before
popping up a help balloon. Specified in milliseconds. Defaults to
350 milliseconds. This applies to both the popped up balloon and
the status bar message.

=item B<-state>

Can be one of B<balloon>, B<status>, B<both> or B<none> indicating
that the help balloon, status bar help, both or none respectively
should be activated when the mouse pauses over the client widget.

=item B<-statusbar>

Specifies the widget used to display the status message. This
widget should accept the B<-text> option and is typically a
B<Label>. If the widget accepts the B<-textvariable> option and
that option is defined then it is used instead of the B<-text>
option.

=item B<-postcommand>

This option takes a CODE reference which is to be executed before
the balloon and statusbar messages are displayed. Useful in combination
with the B<-followmouse> option when used with a B<Text> or B<Canvas>
widget and you want the message to be different depending on what
object in the widget the mouse is over.

=item B<-followmouse>

This option can be set to 0 or 1 and has 2 effects. It will cause
the balloon to be displayed only if the mouse is completely
motionless for the B<-initwait> time interval, and it will make
the balloon appear under and to the right of the mouse.

=item B<-show>

This option can be set to 0 or 1 and will disable or enable the
balloon or statusbar message. Useful in the postcommand if you
want to cancel the current balloon before it is displayed.

=back

=head1 METHODS

The B<Balloon> widget supports only two non-standard methods:

=over 4

=item B<attach(>I<widget>, I<options>B<)>

Attaches the widget indicated by I<widget> to the help system. The
options can be:

=over 4

=item B<-statusmsg>

The argument is the message to be shown on the status bar when the
mouse pauses over this client. If this is not specified, but
B<-msg> is specified then the message displayed on the status bar
is the same as the argument for B<-msg>. If you give it a scalar
reference then it is dereferenced before being displayed. Useful
if the postcommand is used to change the message.

=item B<-balloonmsg>

The argument is the message to be displayed in the balloon that
will be popped up when the mouse pauses over this client. As with
B<-statusmsg> if this is not specified, then it takes its value
from the B<-msg> specification if any. If neither B<-balloonmsg>
nor B<-msg> are specified, or they are the empty string then
no balloon is popped up instead of an empty balloon. If you
give it a scalar reference then it is dereferenced before being
displayed. Useful if the postcommand is used to change the message.

=item B<-msg>

The catch-all for B<-statusmsg> and B<-balloonmsg>. This is a
convenient way of specifying the same message to be displayed in
both the balloon and the status bar for the client.

=back

=item B<detach(>I<widget>B<)>

Detaches the specified widget I<widget> from the help system.

=back

=head1 AUTHORS

B<Rajappa Iyer> rsi@earthling.net did the original coding.
Jason A Smith <smithj4@rpi.edu> added support for menus.

This code and documentation is derived from Balloon.tcl from the
Tix4.0 distribution by Ioi Lam. This code may be redistributed
under the same terms as Perl.

=cut
