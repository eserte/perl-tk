# labels.pl

sub labels {

    # Create a top-level window that displays a bunch of labels.

    my($demo) = @ARG;

    $LABEL->destroy if Exists($LABEL);
    $LABEL = $mw->Toplevel;
    my $w = $LABEL;
    dpos($w);
    $w->title('Label Demonstration');
    $w->iconname('labels');

    my $w_msg = $w->Label(
        -font       => $FONT,
        -wraplength => '4i',
        -justify    => 'left',
        -text       => 'Five labels are displayed below: three textual ones on the left, and a bitmap label and a text label on the right.  Labels are pretty boring because you can\'t do anything with them.',
    );
    $w_msg->pack(-side => 'top');

    my $w_buttons = $w->Frame;
    $w_buttons->pack(qw( -side bottom -expand y -fill x -pady 2m));
    my $w_dismiss = $w_buttons->Button(
        -text    => 'Dismiss',
        -command => ['destroy', $w],
    );
    $w_dismiss->pack(qw(-side left -expand 1));
    my $w_see = $w_buttons->Button(
        -text    => 'See Code',
        -command => [\&seeCode, $demo],
    );
    $w_see->pack(qw(-side left -expand 1));

    my $w_left = $w->Frame;
    my $w_right = $w->Frame;
    my(@pl) = (-side => 'left', -expand => 'yes', -padx => 10, -pady => 10,
	       -fill => 'both');
    $w_left->pack(@pl);
    $w_right->pack(@pl);

    my $w_left_l1 = $w_left->Label(-text => 'First label');
    my $w_left_l2 = $w_left->Label(
        -text => 'Second label, raised just for fun', 
        -relief => 'raised',
    );
    my $w_left_l3 = $w_left->Label(
        -text => 'Third label, sunken',
        -relief => 'sunken',
    );
    @pl = (-side => 'top', -expand => 'yes', -pady => 2, -anchor => 'w');
    $w_left_l1->pack(@pl);
    $w_left_l2->pack(@pl);
    $w_left_l3->pack(@pl);

    my $w_right_bitmap = $w_right->Label(
        -bitmap => "\@$tk_library/demos/images/face",
        -borderwidth => 2,
	-relief => 'sunken',
    );
    my $w_right_caption = $w_right->Label(-text => 'Tcl/Tk Proprietor');
    $w_right_bitmap->pack(-side => 'top');
    $w_right_caption->pack(-side => 'top');

} # end labels

1;
