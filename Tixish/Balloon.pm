#
# The help widget that provides both "balloon" and "status bar"
# types of help messages.
#
# This is a patched version of Balloon 3.037 - it adds support
# for different orientations of the balloon widget, depending
# on wether there's enough space for it. The little arrow now
# should always point directly to the client.
# Added by Gerhard Petrowitsch (gerhard.petrowitsch@philips.com)

package Tk::Balloon;

use vars qw($VERSION);
$VERSION = sprintf '4.%03d', q$Revision: #7 $ =~ /\D(\d+)\s*$/;

use Tk qw(Ev Exists);
use Carp;
require Tk::Toplevel;

Tk::Widget->Construct('Balloon');
use base qw(Tk::Toplevel);

# use UNIVERSAL; avoid the UNIVERSAL.pm file subs are XS in perl core

use strict;

my @balloons;
my $button_up = 0;
my %arrows = ( TL => 'R0lGODlhBgAGAJEAANnZ2QAAAP///////yH5BAEAAAAALAAAAAAGAAYAAAINjA0HAEdwLCwMKIQfBQA7',
	       TR => 'R0lGODlhBgAGAJEAANnZ2QAAAP///////yH5BAEAAAAALAAAAAAGAAYAAAIRBGMDwAEQkgAIAAoCABEEuwAAOw==',
	       BR => 'R0lGODlhBgAGAJEAANnZ2QAAAP///////yH5BAEAAAAALAAAAAAGAAYAAAIPDOHHhYVRAIgIAEISQLELADs=',
	       BL => 'R0lGODlhBgAGAJEAANnZ2QAAAP///////yH5BAEAAAAALAAAAAAGAAYAAAIPhB1xAUFALCIMKAaAWQAVADs=',
	       NO => 'R0lGODlhAQABAJEAANnZ2f///////////yH5BAEAAAAALAAAAAABAAEAAAICRAEAOw=='
	     );


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
    my $d = $w->Frame;
    # the balloon arrows
    $w->{img_tl} = $w->Photo(-data => $arrows{TL}, '-format' => 'gif');
    $w->{img_tr} = $w->Photo(-data => $arrows{TR}, '-format' => 'gif');
    $w->{img_bl} = $w->Photo(-data => $arrows{BL}, '-format' => 'gif');
    $w->{img_br} = $w->Photo(-data => $arrows{BR}, '-format' => 'gif');
    $w->{img_no} = $w->Photo(-data => $arrows{NO}, '-format' => 'gif');
    $w->OnDestroy([$w, '_destroyed']);
    $a->configure(-bd => 0);
    $d->configure(-bd => 0);
    my $atl = $a->Label(-bd => 0,
		       -relief => 'flat',
		       -image => $w->{img_no});
    $atl->pack(-side => 'top', -padx => 1, -pady => 1, -anchor => 'nw');
    my $abl = $a->Label(-bd => 0,
		       -relief => 'flat',
		       -image => $w->{img_no});
    $abl->pack(-side => 'bottom', -padx => 1, -pady => 1, -anchor => 'sw');
    my $dtr = $d->Label(-bd => 0,
		       -relief => 'flat',
		       -image => $w->{img_no});
    $dtr->pack(-side => 'top', -padx => 1, -pady => 1, -anchor => 'ne');
    my $dbr = $d->Label(-bd => 0,
		       -relief => 'flat',
		       -image => $w->{img_no});
    $dbr->pack(-side => 'bottom', -padx => 1, -pady => 1, -anchor => 'se');
    # the balloon message
    $m->configure(-bd => 0);
    my $ml = $m->Label(-bd => 0,
		       -padx => 0,
		       -pady => 0,
		       -text => $args->{-message});
    $w->Advertise('message' => $ml);
    $w->Advertise('TLarrow' => $atl);
    $w->Advertise('TRarrow' => $dtr);
    $w->Advertise('BLarrow' => $abl);
    $w->Advertise('BRarrow' => $dbr);
    $ml->pack(-side => 'left',
	      -anchor => 'w',
	      -expand => 1,
	      -fill => 'both',
	      -padx => 10,
	      -pady => 3);
    $a->pack(-fill => 'both', -side => 'left');
    $m->pack(-fill => 'both', -side => 'left');
    $d->pack(-fill => 'both', -side => 'left');

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
		    -statusmsg => ['PASSIVE', 'statusMsg', 'StatusMsg', ''],
		    -balloonmsg => ['PASSIVE', 'balloonMsg', 'BalloonMsg', ''],
		    -balloonposition => ['PASSIVE', 'balloonPosition', 'BalloonPosition', 'widget'],
#    -balloonanchor => ['PASSIVE', 'balloonAnchor', 'BalloonAnchor', 'nw'],
		    -postcommand => ['CALLBACK', 'postCommand', 'PostCommand', undef],
		    -cancelcommand => ['CALLBACK', 'cancelCommand', 'CancelCommand', undef],
		    -motioncommand => ['CALLBACK', 'motionCommand', 'MotionCommand', undef],
		    -background => ['DESCENDANTS', 'background', 'Background', '#C0C080'],
		    -foreground => ['DESCENDANTS', 'foreground', 'Foreground', undef],
		    -font => [$ml, 'font', 'Font', '-*-helvetica-medium-r-normal--*-120-*-*-*-*-*-*'],
		    -borderwidth => ['SELF', 'borderWidth', 'BorderWidth', 1]
		   );
}

# attach a client to the balloon
sub attach {
    my ($w, $client, %args) = @_;
    foreach my $key (grep(/command$/,keys %args))
     {
      $args{$key} = Tk::Callback->new($args{$key});
     }
    my $msg = delete $args{-msg};
    $args{-balloonmsg} = $msg unless exists $args{-balloonmsg};
    $args{-statusmsg}  = $msg unless exists $args{-statusmsg};
    $w->{'clients'}{$client} = \%args;
    $client->OnDestroy([$w, 'detach', $client]);
}

# detach a client from the balloon.
sub detach {
    my ($w, $client) = @_;
    if (Exists($w))
     {
      $w->Deactivate if ($client->IS($w->{'client'}));
     }
    delete $w->{'clients'}{$client};
}

sub GetOption
{
 my ($w,$opt,$client) = @_;
 $client = $w->{'client'} unless defined $client;
 if (defined $client)
  {
   my $info = $w->{'clients'}{$client};
   return $info->{$opt} if exists $info->{$opt};
  }
 return $w->cget($opt);
}

sub Motion {
    my ($ewin, $x, $y, $s) = @_;

    return if not defined $ewin;

    # Find which window we are over
    my $over = $ewin->Containing($x, $y);

    #return if not defined $ewin or ((($s & 0x1f00) or $ewin->grabCurrent()) and not $ewin->isa('Tk::Menu'));
#    return if $ewin->grabBad($over);
    return if &grabBad($ewin, $over);

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
	    my $state = $w->GetOption(-state => $client);
	    next if $state eq 'none';
	    # Check if a button was recently released:
	    my $deactivate = 0;
	    if ($button_up) {
	      $deactivate = 1;
	      $button_up = 0;
	    }
	    # Deactivate it if the motioncommand says to:
	    my $command = $w->GetOption(-motioncommand => $client);
	    $deactivate = $command->Call($client, $x, $y) if defined $command;
	    if ($deactivate)
	     {
	      $w->Deactivate;
	     }
	    else
	     {
	      # warn "deact: $client $w->{'client'}";
	      $w->Deactivate unless $client->IS($w->{'client'});
	      my $msg = $client->BalloonInfo($w,$x,$y,'-statusmsg','-balloonmsg');
	      if (defined($msg))
	       {
		my $delay = delete $w->{'delay'};
		$delay->cancel if defined $delay;
		my $initwait = $w->GetOption(-initwait => $client);
		$w->{'delay'} = $client->after($initwait, sub {$w->SwitchToClient($client);});
		$w->{'client'} = $client;
	       }
	     }
	} else {
	    # cursor is at a position covered by a non client
	    # pop down the balloon if it is up or scheduled.
	    $w->Deactivate;
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
    #return if $w->grabCurrent and not $client->isa('Tk::Menu');
    #return if $w->grabBad($client);
    return if &grabBad($w, $client);
    my $command = $w->GetOption(-postcommand => $client);
    if (defined $command) {
	# Execute the user's command and return if it returns false:
	my $pos = $command->Call($client);
	return if not $pos;
	if ($pos =~ /^(\d+),(\d+)$/) {
	    # Save the returned position so the Popup method can use it:
	    $w->{'clients'}{$client}{'postposition'} = [$1, $2];
	}
    }
    my $state = $w->GetOption(-state => $client);
    $w->Popup if ($state =~ /both|balloon/);
    $w->SetStatus if ($state =~ /both|status/);
    $w->{'popped'} = 1;
    $w->{'delay'}  = $w->repeat(200, ['Verify', $w, $client]);
}

sub grabBad {

    my ($w, $client) = @_;

    return 0 unless Exists($client);
    my $g = $w->grabCurrent;
    return 0 unless defined $g;
    return 0 if $g->isa('Tk::Menu');
    return 0 if $g eq $client;

    # The grab is OK if $client is a decendant of $g. Use the internal Tcl/Tk
    # pathname (yes, it's cheating, but it's legal).

    return 0 if $g == $w->MainWindow;
    my $wp = $w->PathName;
    my $gp = $g->PathName;
    return 0 if $wp =~ /^$gp/;
    return 1;                   # bad grab

} # end grabBad

sub Subclient
{
 my ($w,$data) = @_;
 if (defined($w->{'subclient'}) && (!defined($data) || $w->{'subclient'} ne $data))
  {
   $w->Deactivate;
  }
 $w->{'subclient'} = $data;
}

sub Verify {
    my $w      = shift;
    my $client = shift;
    my ($X,$Y) = (@_) ? @_ : ($w->pointerxy);
    my $over = $w->Containing($X,$Y);
    return if not defined $over or ($over->toplevel eq $w);
    my $deactivate = # DELETE? or move it to the isa-Menu section?:
		     # ($over ne $client) or
		     not $client->IS($w->{'client'})
#                     or (!$client->isa('Tk::Menu') && $w->grabCurrent);
#                     or $w->grabbad($client);
		     or &grabBad($w, $client);
    if ($deactivate)
     {
      $w->Deactivate;
     }
    else
     {
      $client->BalloonInfo($w,$X,$Y,'-statusmsg','-balloonmsg');
     }
}

sub Deactivate {
    my ($w) = @_;
    my $delay = delete $w->{'delay'};
    $delay->cancel if defined $delay;
    if ($w->{'popped'}) {
	my $client = $w->{'client'};
	my $command = $w->GetOption(-cancelcommand => $client);
	if (defined $command) {
	    # Execute the user's command and return if it returns false:
	    return if not $command->Call($client);
	}
	$w->withdraw;
	$w->ClearStatus;
	$w->{'popped'} = 0;
	$w->{'menu_index'} = 'none';
	$w->{'canvas_tag'} = '';
    }
    $w->{'client'} = undef;
    $w->{'subclient'} = undef;
}

sub Popup {
    my ($w) = @_;
    if ($w->cget(-installcolormap)) {
	$w->colormapwindows($w->winfo('toplevel'))
    }
    my $client = $w->{'client'};
    return if not defined $client or not exists $w->{'clients'}{$client};
    my $msg = $client->BalloonInfo($w, $w->pointerxy,'-balloonmsg');
    # Dereference it if it looks like a scalar reference:
    $msg = $$msg if UNIVERSAL::isa($msg, 'SCALAR');

    $w->Subwidget('message')->configure(-text => $msg);
    $w->idletasks;

    return unless Exists($w);
    return unless Exists($client);
    return if $msg eq '';  # Don't popup empty balloons.

    my ($x, $y);
    my $pos = $w->GetOption(-balloonposition => $client);
#    my $anc = $w->GetOption(-balloonanchor => $client);
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

    $w->idletasks;
    my($width, $height) = ($w->reqwidth, $w->reqheight);
    my($xx, $yy) = ($x,$y);
    my $ex = 0;
    if ($x + $width > $w->screenwidth) {
      $ex |= 1;
    }
    if ($y + $height > $w->screenheight) {
      $ex |= 2;
    }
    if ($ex == 0) {
      $w->Subwidget('TLarrow')->configure(-image => $w->{img_tl});
      $w->Subwidget('TRarrow')->configure(-image => $w->{img_no});
      $w->Subwidget('BLarrow')->configure(-image => $w->{img_no});
      $w->Subwidget('BRarrow')->configure(-image => $w->{img_no});
      ($xx,$yy) = ($x,$y);
    } elsif ($ex == 1) {
      $w->Subwidget('TLarrow')->configure(-image => $w->{img_no});
      $w->Subwidget('TRarrow')->configure(-image => $w->{img_tr});
      $w->Subwidget('BLarrow')->configure(-image => $w->{img_no});
      $w->Subwidget('BRarrow')->configure(-image => $w->{img_no});
      $x = int($client->pointerx - 2) if ($pos eq 'mouse');
      ($xx,$yy) = ($x-$width,$y);
    } elsif ($ex == 2) {
      $w->Subwidget('TLarrow')->configure(-image => $w->{img_no});
      $w->Subwidget('TRarrow')->configure(-image => $w->{img_no});
      $w->Subwidget('BLarrow')->configure(-image => $w->{img_bl});
      $w->Subwidget('BRarrow')->configure(-image => $w->{img_no});
      $x = int($client->pointerx + 2) if ($pos eq 'mouse');
      $y = int($client->pointery - 2) if ($pos eq 'mouse');
      $y = int($client->rooty + int ($client->height/4.3)) if ($pos eq 'widget');
      ($xx,$yy) = ($x,$y-$height);
    } else {
      $w->Subwidget('TLarrow')->configure(-image => $w->{img_no});
      $w->Subwidget('TRarrow')->configure(-image => $w->{img_no});
      $w->Subwidget('BLarrow')->configure(-image => $w->{img_no});
      $w->Subwidget('BRarrow')->configure(-image => $w->{img_br});
      $x = int($client->pointerx - 2) if ($pos eq 'mouse');
      $y = int($client->pointery - 2) if ($pos eq 'mouse');
      $y = int($client->rooty + int ($client->height/4.3)) if ($pos eq 'widget');
      ($xx,$yy) = ($x-$width,$y-$height);
    }

    $w->geometry("+$xx+$yy");
    #$w->MoveToplevelWindow($x,$y);
    $w->deiconify();
    $w->raise;
    #$w->update;  # This can cause confusion by processing more Motion events before this one has finished.
}

sub SetStatus {
    my ($w) = @_;
    my $client = $w->{'client'};
    my $s = $w->GetOption(-statusbar => $client);
    if (defined $s and $s->winfo('exists')) {
	my $vref = $s->cget(-textvariable);
	return if not defined $client or not exists $w->{'clients'}{$client};
	my $msg = $client->BalloonInfo($w, $w->pointerxy,'-statusmsg');
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
    my $s = $w->GetOption(-statusbar => $client);
    if (defined $s and $s->winfo('exists')) {
	my $vref = $s->cget(-textvariable);
	if (defined $vref) {
	    $$vref = '';
	} else {
	    eval { $s->configure(-text => ''); }
	}
    }
}

sub _destroyed
{
    my ($w) = @_;
    # This is called when widget is destroyed (no matter how!)
    # via the ->OnDestroy hook set in Populate.
    # remove ourselves from the list of baloons.
    @balloons = grep($w != $_, @balloons);

    # FIXME: If @balloons is now empty perhaps remove the 'all' bindings
    # to reduce overhead until another balloon is created?

    # Delete the images
    for (qw(no tl tr bl br)) {
        my $img = delete $w->{"img_$_"};
	$img->delete if defined $img;
    }
}

1;

