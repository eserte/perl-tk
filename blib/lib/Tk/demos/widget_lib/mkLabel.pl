

sub mkLabel {

    # Create a top-level window that displays a bunch of labels.

    $mkLabel->destroy if Exists($mkLabel);
    $mkLabel = $top->Toplevel();
    my $w = $mkLabel;
    dpos($w);
    $w->title('Label Demonstration');
    $w->iconname('Labels');

    my $w_msg = $w->Message(-font => '-Adobe-times-medium-r-normal--*-180-*-*-*-*-*-*', -aspect => 300,
			     -text => 'Five labels are displayed below: three textual ones on the left, and a bitmap label ' .
			     'and a text label on the right.  Labels are pretty boring because you can\'t do anything with ' .
			     'them.  Click the "OK" button when you\'ve seen enough.');
    my $w_left = $w->Frame();
    my $w_right = $w->Frame();
    my $w_ok = $w->Button(-text => 'OK', -command => ['destroy', $w], -width => 8);
    $w_msg->pack(-side => 'top');
    $w_ok->pack(-side => 'bottom');
    my(@pl) = (-side => 'left', -expand => 'yes', -padx => 10, -pady => 10, -fill => 'both');
    $w_left->pack(@pl);
    $w_right->pack(@pl);

    my $w_left_l1 = $w_left->Label(-text => 'First label');
    my $w_left_l2 = $w_left->Label(-text => 'Second label, raised just for fun', -relief => 'raised');
    my $w_left_l3 = $w_left->Label(-text => 'Third label, sunken', -relief => 'sunken');
    @pl = (-side => 'top', -expand => 'yes', -pady => 2, -anchor => 'w');
    $w_left_l1->pack(@pl);
    $w_left_l2->pack(@pl);
    $w_left_l3->pack(@pl);

    my $w_right_bitmap = $w_right->Label(-bitmap => '@'.Tk->findINC('demos/images/face'), -borderwidth => 2,
				    -relief => 'sunken');
    my $w_right_caption = $w_right->Label(-text => 'Tcl/Tk Proprietor');
    $w_right_bitmap->pack(-side => 'top');
    $w_right_caption->pack(-side => 'top');

} # end mkLabel


1;
