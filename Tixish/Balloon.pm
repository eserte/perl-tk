#
# The help widget that provides both "balloon" and "status bar"
# types of help messages.

package Tk::Balloon;

use vars qw($VERSION);
$VERSION = '3.030'; # $Id: //depot/Tk8/Tixish/Balloon.pm#30 $

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
		    -statusmsg => ['PASSIVE', 'statusMsg', 'StatusMsg', ''],
		    -balloonmsg => ['PASSIVE', 'balloonMsg', 'BalloonMsg', ''],
		    -balloonposition => ['PASSIVE', 'balloonPosition', 'BalloonPosition', 'widget'],
		    -postcommand => ['CALLBACK', 'postCommand', 'PostCommand', undef],
		    -cancelcommand => ['CALLBACK', 'cancelCommand', 'CancelCommand', undef],
		    -motioncommand => ['CALLBACK', 'motionCommand', 'MotionCommand', undef],
		    -background => ['DESCENDANTS', 'background', 'Background', '#C0C080'],
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
    return unless Exists($w);
    $w->Deactivate if ($client->IS($w->{'client'}));
    delete $w->{'clients'}{$client};
}                                    

sub GetOption
{
 my ($w,$opt,$client) = @_;
 $client = $w->{'client'} unless $client;
 my $info = $w->{'clients'}{$client};
 return $info->{$opt} if exists $info->{$opt};
 return $w->cget($opt);
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
	    $deactivate = $command->Call if defined $command;
            if ($deactivate)
             {
              $w->Deactivate;
             }
            else
             {
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
    return if $w->grabCurrent and not $client->isa('Tk::Menu');
    my $command = $w->GetOption(-postcommand => $client);
    if (defined $command) {
	# Execute the user's command and return if it returns false:
	my $pos = $command->Call;
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
    my $deactivate = ($over ne $client) or not $client->IS($w->{'client'}) 
                     or (!$client->isa('Tk::Menu') && $w->grabCurrent);
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
	    return if not $command->Call;
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

sub Tk::Canvas::BalloonInfo
{
 my ($canvas,$balloon,$X,$Y,@opt) = @_;
 my @tags = ($canvas->find('withtag', 'current'),$canvas->gettags('current'));
 foreach my $opt (@opt)
  {
   my $info = $balloon->GetOption($opt,$canvas);
   if ($opt =~ /^-(statusmsg|balloonmsg)$/ && UNIVERSAL::isa($info,'HASH'))
    {                     
     $balloon->Subclient($tags[0]);
     foreach my $tag (@tags) 
      {              
       return $info->{$tag} if exists $info->{$tag};
      }         
     return ''; 
    }           
   return $info;
  }
}                                  

sub Tk::Menu::BalloonInfo
{
 my ($menu,$balloon,$X,$Y,@opt) = @_;
 my $i = $menu->index('active');
 if ($i eq 'none') 
  {
   my $y = $Y - $menu->rooty;
   $i = $menu->index("\@$y");
  }                             
 foreach my $opt (@opt)
  {
   my $info = $balloon->GetOption($opt,$menu);
   if ($opt =~ /^-(statusmsg|balloonmsg)$/ && UNIVERSAL::isa($info,'ARRAY'))
    {           
     $balloon->Subclient($i);
     return '' if $i eq 'none';
     return ${$info}[$i] || '';
    }           
   return $info;
  }
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
    my $xx = ($x + $width > $w->screenwidth
	      ? $w->screenwidth - $width
	      : $x);
    my $yy = ($y + $height > $w->screenheight
	      ? $w->screenheight - $height
	      : $y);

    $w->geometry("+$xx+$yy");
    #$w->MoveToplevelWindow($x,$y);
    $w->deiconify();
    $w->raise;
    #$w->update;  # This can cause confusion by processing more Motion events before this one has finished.
}                                           

sub Tk::Widget::BalloonInfo
{
 my ($widget,$balloon,$X,$Y,@opt) = @_;
 foreach my $opt (@opt)
  {
   my $info = $balloon->GetOption($opt,$widget);
   return $info if defined $info;
  }
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

sub destroy {
    my ($w) = @_;
    @balloons = grep($w != $_, @balloons);
    #$w->SUPER::destroy;
    # Above doesn't seem to work but at least I have removed it from the
    # list of balloons and maybe undef'ing the object will get rid of it.
    undef $w;
}

1;

