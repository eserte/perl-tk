# $Id: Balloon.pm,v 1.2 1996/12/02 00:33:41 rsi Exp $
#
# The help widget that provides both "balloon" and "status bar"
# types of help messages.

package Tk::Balloon;

use Tk qw(Ev);
use Carp;
require Tk::Toplevel;

Tk::Widget->Construct("Balloon");
@Tk::Balloon::ISA = qw(Tk::Toplevel);

my @balloons;

sub ClassInit {
    my ($class, $mw) = @_;
    $mw->bind("all", "<Motion>", ['Tk::Balloon::Motion', Ev('X'), Ev('Y')]);
    $mw->bind("all", "<Leave>", ['Tk::Balloon::Motion', Ev('X'), Ev('Y')]);
    $mw->bind("all", "<Button>", ['Tk::Balloon::ButtonDown', Ev('X'), Ev('Y'), Ev('b')]);
    $mw->bind("all", "<ButtonRelease>", ['Tk::Balloon::ButtonUp', Ev('X'), Ev('Y'), Ev('b')]);
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
    $w->ConfigSpecs(-installcolormap => ["PASSIVE", "installColormap", "InstallColormap", 0],
		    -initwait => ["PASSIVE", "initWait", "InitWait", 350],
		    -state => ["PASSIVE", "state", "State", "both"],
		    -statusbar => ["PASSIVE", "statusBar", "StatusBar", undef],
		    -background => ["DESCENDANTS", "background", "Background", "#ffff60"],
		    -font => [$ml, "font", "Font", "-*-helvetica-medium-r-normal-*-12-*-*-*-*-*-*"],
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
}

# detach a client from the balloon.
sub detach {
    my ($w, $client) = @_;
    delete $w->{"clients"}->{$client};
}

sub Motion {
    my ($w, $x, $y) = @_;
    my $b;

    foreach $bal (@balloons) {
	$bal->_Motion($x, $y);
    }
}

sub ButtonDown {
    my ($w, $x, $y, $b) = @_;
    my $bal;

    foreach $bal (@balloons) {
	$bal->_ButtonDown($x, $y, $b);
    }
}

sub ButtonUp {
    my ($w, $x, $y, $b) = @_;
    my $bal;

    foreach $bal (@balloons) {
	$bal->_ButtonUp($x, $y, $b);
    }
}

sub _Motion {
    my ($w, $x, $y) = @_;

    return if (($w->cget(-state) eq "none") || 	# popping up disabled
	       ($w->{"buttonDown"}) ||		# button is already down
	       (defined $w->grabCurrent()));	# somebody else has screen

    my $cw = $w->Containing($x, $y);
    # if cursor hash moved over the balloon -- ignore
    return if ((defined $cw) && $cw->toplevel eq $w);

    # find the client window that matches
    while (defined $cw) {
	last if (exists $w->{"clients"}->{$cw});
	$cw = $cw->winfo("parent");
    }
    if (not defined $cw) {
	# cursor is at a position covered by a non client
	# pop down the balloon if it is up
	if ($w->{"popped"}) {
	    $w->Deactivate;
	}
	$w->{"client"} = undef;
	return;
    }
    unless ($cw->IS($w->{"client"})) {  
	if ($w->{"popped"}) {
	    $w->Deactivate;
	}
	$w->{"client"} = $cw;
	Tk->after($w->cget(-initwait), sub {$w->SwitchToClient($cw);});
    }
}

sub _ButtonDown {
    my ($w, $x, $y, $b) = @_;

    # call motion binding
    $w->Motion($x, $y);
    $w->{"buttonDown"}++;

    return if (defined $w->grabCurrent());

    if ($w->{"popped"}) {
	$w->Deactivate;
    } else {
	$w->{"cancel"} = 1;
    }
}

sub _ButtonUp {
    my ($w, $x, $y, $b) = @_;
    $w->Motion($x, $y);
    $w->{"buttonDown"}--;
}

# switch the balloon to a new client
sub SwitchToClient {
    my ($w, $client) = @_;
    return if ((not $w->winfo("exists")) &&
	       (not $client->winfo("exists")) &&
	       ($client ne $w->{"client"})
	      );
    if (defined $w->{"cancel"} && $w->{"cancel"}) {
	$w->{"cancel"} = undef;
	return;
    }
    if ($w->grabCurrent) {
	return;
    }
    $w->Activate;
}

sub ClientDestroy {
    my ($w, $client) = @_;
    return if (!$w->winfo("exists"));
    if ($w->{"client"} ne $client) {
	$w->Deactivate;
	$w->{"client"} = undef;
	delete $w->{"clients"}->{$client};
    }
}

sub Activate {
    my ($w) = @_;
    if ($w->cget(-state) =~ /both|balloon/) {
	$w->Popup;
    }
    if ($w->cget(-state) =~ /both|status/) {
	$w->SetStatus;
    }
    $w->{"popped"} = 1;
    Tk->after(200, sub {$w->Verify;});
}

sub Verify {
    my ($w) = @_;
    return if ((not $w->winfo("exists")) ||
	       (!$w->{"popped"}));
    if ($w->grabCurrent) {
	$w->Deactivate;
	return;
    }
    Tk->after(200, sub {$w->Verify;});
}

sub Deactivate {
    my ($w) = @_;
    $w->Popdown;
    $w->ClearStatus;
    $w->{"popped"} = 0;
    $w->{"cancel"} = undef;
}

sub Popup {
    my ($w) = @_;
    if ($w->cget(-installcolormap)) {
	$w->colormapwindows($w->winfo("toplevel"))
    }
    my $client = $w->{"client"};
    return if (not defined $client);
    return if (not exists $w->{"clients"}->{$client});
    my $msg = $w->{"clients"}->{$client}->{-balloonmsg};
    $w->Subwidget("message")->configure(-text => $msg);
    $w->geometry("+10000+10000");
    $w->deiconify();
    $w->raise;
    $w->update;

    return if (not $w->winfo("exists"));
    return if (not $client->winfo("exists"));

    my $x = int($client->winfo("rootx") + $client->winfo("width")/2);
    my $y = int($client->winfo("rooty") + int ($client->winfo("height")/1.3));
    $w->geometry("+$x+$y");
}

sub Popdown {
    my ($w) = @_;
    $w->withdraw;
}

sub SetStatus {
    my ($w) = @_;
    my $s = $w->cget(-statusbar);
    if ((defined $s) && $s->winfo("exists")) {
	my $vref = $s->cget(-textvariable);
	my $client = $w->{"client"};
	return if (not defined $client);
	return if (not exists $w->{"clients"}->{$client});
	my $msg = $w->{"clients"}->{$client}->{-statusmsg} || '';
	if (not defined $vref) {
	    eval { $s->configure(-text => $msg) };
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

1;

__END__

=head1 NAME

Tk::Balloon - pop up help balloons.

=head1 SYNOPSIS

    use Tk::Balloon;
    ...
    $b = $top->Balloon(-statusbar => $status_bar_widget);
    $b->attach($widget,
	       -balloonmsg => "Balloon help message",
	       -statusmsg => "Status bar message");

=head1 DESCRIPTION

B<Balloon> provides the framework to create and attach help
balloons to various widgets so that when the mouse pauses over the
widget for more than a specified amount of time, a help balloon is
poppped up.

B<Balloon> accepts all the options that the B<Frame> widget
accepts. In addition, the following options are also recognized.

=over 4

=item B<-initwait>

Specifies the amount of time to wait without activity before
popping up a help balloon. Specified in milliseconds. Defaults to
350 milliseconds.

=item B<-state>

Can be one of B<balloon>, B<status>, B<both> or B<none> indicating
that the help balloon, status bar help, both or none respectively
should be activated when the mouse pauses over the client widget.

=item B<-statusbar>

Specifies the widget used to display the status message. This
widget should accept the B<-text> option and is typically a
B<Label>.

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
is the same as the argument for B<-msg>.

=item B<-balloonmsg>

The argument is the message to be displayed in the balloon that
will be popped up when the mouse pauses over the client. As with
B<-statusmsg> if this is not specified, then it takes its value
from the B<-msg> specification as any. If neither B<-balloonmsg>
nor B<-msg> are specified, then an empty balloon will be popped
up... this is silly, but there it is.

=item B<-msg>

The catch-all for B<-statusmsg> and B<-balloonmsg>. This is a
convenient way of specifying the same message to be displayed in
both the balloon and the status bar for the client.

=back

=item B<detach(>I<widget>B<)>

Detaches the specified widget I<widget> from the help system.

=back

=head1 AUTHOR

B<Rajappa Iyer> rsi@ziplink.net

This code and documentation is derived from Balloon.tcl from the
Tix4.0 distribution by Ioi Lam. This code may be redistributed
under the same terms as Perl.

=cut

