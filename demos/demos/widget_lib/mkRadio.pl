

sub mkRadio {

    # Create a top-level window that displays a bunch of radio buttons.

    $mkRadio->destroy if Exists($mkRadio);
    $mkRadio = $top->Toplevel();
    my $w = $mkRadio;
    dpos $w;
    $w->title('Radiobutton Demonstration');
    $w->iconname('Radiobuttons');
    my $w_msg = $w->Message(-font => '-Adobe-times-medium-r-normal--*-180-*-*-*-*-*-*', -aspect => '300', -text =>
			     'Two groups of radiobuttons are displayed below.  If you click on a button then the button ' .
			     'will become selected exclusively among all the buttons in its group.  A Perl variable is ' .
			     'associated with each group to indicate which of the group\'s buttons is selected.  Click the ' .
			     '"See Variables" button to see the current values of the variables.  Click the "OK" button ' .
			     'when you\'ve seen enough.');
    my $w_frame = $w->Frame(-borderwidth => '10');
    my $w_frame2 = $w->Frame();
    my(@pl) = (-side => 'top');
    $w_msg->pack(@pl);
    $w_msg->pack(-side => 'top');
    $w_frame->pack(@pl, -fill => 'x', -pady => '10');
    $w_frame2->pack(@pl, -fill => 'x');

    my $w_frame_left = $w_frame->Frame();
    my $w_frame_right = $w_frame->Frame();
    @pl = (-side => 'left', -expand => 'yes');
    $w_frame_left->pack(@pl);
    $w_frame_right->pack(@pl);

    $size = '' if not defined $size;
    $color = '' if not defined $color;
    my $w_frame_left_b1 = $w_frame_left->Radiobutton(-text => 'Point Size 10', -variable => \$size, -relief => 'flat',
					   -value => '10');
    my $w_frame_left_b2 = $w_frame_left->Radiobutton(-text => 'Point Size 12', -variable => \$size, -relief => 'flat',
					   -value => '12');
    my $w_frame_left_b3 = $w_frame_left->Radiobutton(-text => 'Point Size 18', -variable => \$size, -relief => 'flat',
					   -value => '18');
    my $w_frame_left_b4 = $w_frame_left->Radiobutton(-text => 'Point Size 24', -variable => \$size, -relief => 'flat',
					   -value => '24');
    @pl = (-side => 'top', -pady => '2', -anchor => 'w');
    $w_frame_left_b1->pack(@pl);
    $w_frame_left_b2->pack(@pl);
    $w_frame_left_b3->pack(@pl);
    $w_frame_left_b4->pack(@pl);

    my $w_frame_right_b1 = $w_frame_right->Radiobutton(-text => 'Red', -variable => \$color, -relief => 'flat',
					    -value => 'red');
    my $w_frame_right_b2 = $w_frame_right->Radiobutton(-text => 'Green', -variable => \$color, -relief => 'flat',
					    -value => 'green');
    my $w_frame_right_b3 = $w_frame_right->Radiobutton(-text => 'Blue', -variable => \$color, -relief => 'flat',
					    -value => 'blue');
    my $w_frame_right_b4 = $w_frame_right->Radiobutton(-text => 'Yellow', -variable => \$color, -relief => 'flat',
					    -value => 'yellow');
    my $w_frame_right_b5 = $w_frame_right->Radiobutton(-text => 'Orange', -variable => \$color, -relief => 'flat',
					    -value => 'orange');
    my $w_frame_right_b6 = $w_frame_right->Radiobutton(-text => 'Purple', -variable => \$color, -relief => 'flat',
					    -value => 'purple');
    @pl = (-side => 'top', -pady => '2', -anchor => 'w');
    $w_frame_right_b1->pack(@pl);
    $w_frame_right_b2->pack(@pl);
    $w_frame_right_b3->pack(@pl);
    $w_frame_right_b4->pack(@pl);
    $w_frame_right_b5->pack(@pl);
    $w_frame_right_b6->pack(@pl);

    my $w_frame2_ok = $w_frame2->Button(-text => 'OK', -command => ['destroy', $w], -width => '12');
    my $w_frame2_vars = $w_frame2->Button(-text => 'See Variables', -width => '12',
				    -command => [\&showVars, $w, 'size', 'color']);
    @pl = (-side => 'left', -expand => 'yes');
    $w_frame2_ok->pack(@pl);
    $w_frame2_vars->pack(@pl);

} # end mkRadio


1;
