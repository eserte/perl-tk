

sub mkCheck {

    # Create a top-level window that displays a bunch of check buttons.

    $mkCheck->destroy if Exists($mkCheck);
    $mkCheck = $top->Toplevel();
    my $w = $mkCheck;
    dpos $w;
    $w->title('Checkbutton demonstration');
    $w->iconname('Checkbuttons');
    my $w_msg = $w->Message(-font => '-Adobe-times-medium-r-normal--*-180-*-*-*-*-*-*', -aspect => '300', -text => 'Three ' .
			     'checkbuttons are displayed below.  If you click on a button, it will toggle the button\'s ' .
			     'selection state and set a Perl variable to a value indicating the state of the checkbutton.  ' .
			     'Click the "See Variables" button to see the current values of the variables.  Click the "OK" ' .
			     'button when you\'ve seen enough.');
    my $w_frame = $w->Frame(-borderwidth => '10');
    my $w_frame2 = $w->Frame();

    my(@pl) = (-side => 'top', -fill => 'both');
    $w_msg->pack(@pl);
    $w_frame->pack(@pl, -expand => 'yes');
    $w_frame2->pack(@pl);

    $wipers = 0 if not defined $wipers;
    $brakes = 0 if not defined $brakes;
    $sober = 0 if not defined $sober;
    my $w_frame_b1 = $w_frame->Checkbutton(-text => 'Wipers OK', -variable => \$wipers, -relief => 'flat');
    my $w_frame_b2 = $w_frame->Checkbutton(-text => 'Brakes OK', -variable => \$brakes, -relief => 'flat');
    my $w_frame_b3 = $w_frame->Checkbutton(-text => 'Driver Sober', -variable => \$sober, -relief => 'flat');
    @pl = (-side => 'top', -pady => '2', -expand => 'yes', -anchor => 'w');
    $w_frame_b1->pack(@pl);
    $w_frame_b2->pack(@pl);
    $w_frame_b3->pack(@pl);

    my $w_frame2_ok = $w_frame2->Button(-text => 'OK', -width => 12, -command => ['destroy', $w]);
    my $w_frame2_vars = $w_frame2->Button(-text => 'See Variables', -width => 12,
				    -command => [\&showVars, $w, 'wipers', 'brakes', 'sober']);
    @pl = (-side => 'left', -expand => 'yes');
    $w_frame2_ok->pack(@pl);
    $w_frame2_vars->pack(@pl);

} # end mkcheck


1;
