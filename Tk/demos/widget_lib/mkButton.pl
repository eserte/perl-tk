

sub mkButton {

    # Create a top-level window that displays a bunch of buttons.

    $mkButton->destroy if Exists($mkButton);
    $mkButton = $top->Toplevel();
    my $w = $mkButton;
    dpos $w;
    $w->title('Button Demonstration');
    $w->iconname('Buttons');

    my $w_msg = $w->Message(-font => '-Adobe-times-medium-r-normal--*-180-*-*-*-*-*-*', -aspect => 300,
			     -text => 'If you click on any of the top four buttons below, the background of the button ' .
			     'area will change to the color indicated in the button.  Click the "OK" button when you\'ve ' .
			     'seen enough.');
    $w_msg->pack(-side => 'top', -fill => 'both');

    my($w_b1, $w_b2, $w_b3, $w_b4, $w_ok);
    $w_b1 = $w->Button(-text => 'Peach Puff', -width => 10, -command => [sub {shift->configure(-bg => 'PeachPuff1')}, $w]);
    $w_b2 = $w->Button(-text => 'Light Blue', -width => 10, -command => [sub {shift->configure(-bg => 'LightBlue1')}, $w]);
    $w_b3 = $w->Button(-text => 'Sea Green', -width => 10, -command => [sub {shift->configure(-bg => 'SeaGreen2')}, $w]);
    $w_b4 = $w->Button(-text => 'Yellow', -width => 10, -command => [sub {shift->configure(-bg => 'Yellow1')}, $w]);
    $w_ok = $w->Button(-text => 'OK', -width => 10, -command => ['destroy', $w]);
    my(@pl) = (-side => 'top', -expand => 'yes', -pady => 2);
    $w_b1->pack(@pl);
    $w_b2->pack(@pl);
    $w_b3->pack(@pl);
    $w_b4->pack(@pl);
    $w_ok->pack(@pl);

} # end mkButton


1;
