#
# DialogBox is similar to Dialog except that it allows any widget
# in the top frame. Widgets can be added with the add method. Currently
# there exists no way of deleting a widget once it has been added.

package Tk::DialogBox;

use strict;
use Carp;

use vars qw($VERSION);
$VERSION = '3.032'; # $Id: //depot/Tk8/Tixish/DialogBox.pm#32 $

use base  qw(Tk::Toplevel);

Tk::Widget->Construct('DialogBox');

sub Populate {
    my ($cw, $args) = @_;

    $cw->SUPER::Populate($args);
    my $buttons = delete $args->{'-buttons'};
    $buttons = ['OK'] unless defined $buttons;
    my $default_button = delete $args->{'-default_button'};
    $default_button = $buttons->[0] unless defined $default_button;

    $cw->{'selected_button'} = '';
    $cw->transient($cw->Parent->toplevel);
    $cw->withdraw;
    $cw->protocol('WM_DELETE_WINDOW' => sub {});

    # create the two frames
    my $top = $cw->Component('Frame', 'top');
    $top->configure(-relief => 'raised', -bd => 1) unless $Tk::platform eq 'MSWin32';
    my $bot = $cw->Component('Frame', 'bottom');
    $bot->configure(-relief => 'raised', -bd => 1) unless $Tk::platform eq 'MSWin32';
    $bot->pack(qw/-side bottom -fill both -ipady 3 -ipadx 3/);
    $top->pack(qw/-side top -fill both -ipady 3 -ipadx 3 -expand 1/);

    # create a row of buttons in the bottom.
    my $bl;  # foreach my $var: perl > 5.003_08
    foreach $bl (@$buttons)
     {
	my $b = $bot->Button(-text => $bl, -command => sub { $cw->{'selected_button'} = "$bl" } );
	$cw->Advertise("B_$bl" => $b);
        if ($Tk::platform eq 'MSWin32')
         {
          $b->configure(-width => 10, -pady => 0);
         }
	if ($bl eq $default_button) {
            if ($Tk::platform eq 'MSWin32') {
                $b->pack(-side => 'left', -expand => 1,  -padx => 1, -pady => 1);
            } else {
	        my $db = $bot->Frame(-relief => 'sunken', -bd => 1);
	        $b->raise($db);
	        $b->pack(-in => $db, -padx => '2', -pady => '2');
	        $db->pack(-side => 'left', -expand => 1, -padx => 1, -pady => 1);
            }
	    $cw->bind('<Return>' => [ $b, 'Invoke']);
	    $cw->{'default_button'} = $b;
	} else {
	    $b->pack(-side => 'left', -expand => 1,  -padx => 1, -pady => 1);
	}
    }
    $cw->ConfigSpecs(-command    => ['CALLBACK', undef, undef, undef ],
                     -foreground => ['DESCENDANTS', 'foreground','Foreground', 'black'],
                     -background => ['DESCENDANTS', 'background','Background',  undef],
                    );
    $cw->Delegates('Construct',$top);
}

sub add {
    my ($cw, $wnam, @args) = @_;
    my $w = $cw->Subwidget('top')->$wnam(@args);
    $cw->Advertise("\L$wnam" => $w);
    return $w;
}

sub Wait
{
 my $cw = shift;
 $cw->waitVariable(\$cw->{'selected_button'});
 $cw->grabRelease;
 $cw->withdraw;
 $cw->Callback(-command => $cw->{'selected_button'});
}

sub Show {
    my ($cw, $grab) = @_;
    croak 'DialogBox: "Show" method requires at least 1 argument'
	if scalar @_ < 1;
    my $old_focus = $cw->focusSave;
    my $old_grab = $cw->grabSave;

    $cw->Popup();

    Tk::catch {
    if (defined $grab && length $grab && ($grab =~ /global/)) {
	$cw->grabGlobal;
    } else {
	$cw->grab;
    }
    };
    if (defined $cw->{'default_button'}) {
	$cw->{'default_button'}->focus;
    } else {
	$cw->focus;
    }
    $cw->Wait;
    &$old_focus;
    &$old_grab;
    return $cw->{'selected_button'};
}

1;
