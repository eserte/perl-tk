# $Id: DialogBox.pm,v 1.3 1996/09/02 21:42:11 rsi Exp $
#
# DialogBox is similar to Dialog except that it allows any widget 
# in the top frame. Widgets can be added with the add method. Currently
# there exists no way of deleting a widget once it has been added.

package Tk::DialogBox;

use English;
use Carp;

require Tk::Toplevel;
require Tk::Frame;

@ISA = qw(Tk::Toplevel Tk::Frame);

Tk::Widget->Construct("DialogBox");

sub Populate {
    my ($cw, $args) = @_;
    
    $cw->SUPER::Populate($args);
    my $buttons = delete $args->{"-buttons"};
    $buttons = ["OK"] unless defined $buttons;
    my $default_button = delete $args->{"-default_button"};
    $default_button = $buttons->[0] unless defined $default_button;

    $cw->{"selected_button"} = '';
    $cw->withdraw;
    $cw->protocol("WM_DELETE_WINDOW" => sub {});
    $cw->transient($cw->toplevel);

    # create the two frames
    my $top = $cw->Component(Frame, "top");
    $top->configure(-relief => "raised", -bd => 1);
    $top->pack(-side => "top", -fill => "both", -ipady => 3, -ipadx => 3);
    my $bot = $cw->Component(Frame, "bottom");
    $bot->configure(-relief => "raised", -bd => 1);
    $bot->pack(-side => "top", -fill => "both", -ipady => 3, -ipadx => 3);
    
    # create a row of buttons in the bottom.
    foreach $bl (@$buttons) {
	$b = $bot->Button(-text => $bl,
			  -command => [ sub {
			      $_[0]->{"selected_button"} = $_[1];
			  }, $cw, $bl]);
	if ($bl eq $default_button) {
	    $db = $bot->Frame(-relief => "sunken", -bd => 1);
	    $b->raise($db);
	    $b->pack(-in => $db, -padx => "2", -pady => "2");
	    $db->pack(-side => "left", -expand => 1, -padx => 1, -pady => 1);
	    $cw->bind("<Return>" => [ sub {
		$_[2]->flash;
		$_[1]->{"selected_button"} = $_[3];
	    }, $cw, $b, $bl]);
	    $cw->{"default_button"} = $b;
	} else {
	    $b->pack(-side => "left", -expand => 1,  -padx => 1, -pady => 1);
	}
    }
}

sub add {
    my ($cw, $wnam, %args) = @_;
    my $w = $cw->Subwidget("top")->$wnam(%args);
    $cw->Advertise("\L$wnam" => $w);
    return $w;
}

sub Show {
    my ($cw, $grab) = @_;
    croak "DialogBox: `Show' method requires at least 1 argument"
	if scalar @_ < 1;
    my $old_focus = $cw->focusSave;
    my $old_grab = $cw->grabSave;
    
    $cw->Subwidget("top")->pack;
    $cw->Subwidget("bottom")->pack;
    
    $cw->Popup();
    if (defined $grab && length $grab && ($grab =~ /global/)) {
	$cw->grabGlobal;
    } else {
	$cw->grab;
    }
    $cw->waitVisibility;
    if (defined $cw->{"default_button"}) {
	$cw->{"default_button"}->focus;
    } else {
	$cw->focus;
    }
    $cw->waitVariable(\$cw->{"selected_button"});
    $cw->grabRelease;
    $cw->withdraw;
    &$old_focus;
    &$old_grab;
    return $cw->{"selected_button"};
}

1;

#
# $Log: DialogBox.pm,v $
# Revision 1.3  1996/09/02 21:42:11  rsi
# Changed the side of packing the buttons to the left.
#
# Revision 1.2  1996/09/01 18:50:46  rsi
# Added borders.
# Changed the order of the buttons.
# Added spacing.
# Added the `add' method for widgets.
#
# Revision 1.1  1996/08/29 21:45:35  rsi
# Initial revision
#

