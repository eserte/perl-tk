# entry2.pl

sub entry2 {

    # Create a top-level window that displays a bunch of entries with
    # scrollbars.

    my($demo) = @ARG;

    $ENTRY2->destroy if Exists($ENTRY2);
    $ENTRY2 = $MW->Toplevel;
    my $w = $ENTRY2;
    dpos $w;
    $w->title('Entry Demonstration (with scrollbars)');
    $w->iconname('entry2');

    my $w_msg = $w->Label(
        -font       => $FONT,
        -wraplength => '5i',
	-justify    => 'left',
        -text       => 'Three different entries are displayed below, with a scrollbar for each entry.  You can add characters by pointing, clicking and typing.  The normal Motif editing characters are supported, along with many Emacs bindings.  For example, Backspace and Control-h delete the character to the left of the insertion cursor and Delete and Control-d delete the chararacter to the right of the insertion cursor.  For entries that are too large to fit in the window all at once, you can scan through the entries by dragging with mouse button2 pressed.',
    );
    $w_msg->pack;

    my $w_buttons = $w->Frame;
    $w_buttons->pack(qw(-side bottom -expand y -fill x -pady 2m));
    my $w_dismiss = $w_buttons->Button(
        -text    => 'Dismiss',
        -command => [$w => 'destroy'],
    );
    $w_dismiss->pack(qw(-side left -expand 1));
    my $w_see = $w_buttons->Button(
        -text    => 'See Code',
        -command => [\&seeCode, $demo],
    );
    $w_see->pack(qw(-side left -expand 1));

    my $w_frame = $w->Frame(-borderwidth => '10');
    my (@pl) = (-side => 'top', -fill => 'x', -expand => 1);
    $w_frame->pack(@pl);
    my $w_frame_e1 = $w_frame->Entry(-relief => 'sunken');
    my $w_frame_s1 = $w_frame->Scrollbar(
        -relief  => 'sunken', 
        -orient  => 'horiz', 
        -command => [$w_frame_e1 => 'xview'],
    );
    $w_frame_e1->configure(-xscrollcommand => [$w_frame_s1 => 'set']);
    my $w_frame_spacer1 = $w_frame->Frame(-width => 20, -height => 10);
    my $w_frame_e2 = $w_frame->Entry(-relief => 'sunken');
    my $w_frame_s2 = $w_frame->Scrollbar(
        -relief  => 'sunken',
        -orient  => 'horiz',
        -command => [$w_frame_e2 => 'xview'],
    );
    $w_frame_e2->configure(-xscrollcommand => [$w_frame_s2 => 'set']);
    my $w_frame_spacer2 = $w_frame->Frame(-width => 20, -height => 10);
    my $w_frame_e3 = $w_frame->Entry(-relief => 'sunken');
    my $w_frame_s3 = $w_frame->Scrollbar(
        -relief  => 'sunken',
        -orient  => 'horiz', 
        -command => [$w_frame_e3 => 'xview'],
    );
    $w_frame_e3->configure(-xscrollcommand => [$w_frame_s3 => 'set']);
    @pl = (-side => 'top', -fill => 'x');
    $w_frame_e1->pack(@pl);
    $w_frame_s1->pack(@pl);
    $w_frame_spacer1->pack(@pl);
    $w_frame_e2->pack(@pl);
    $w_frame_s2->pack(@pl);
    $w_frame_spacer2->pack(@pl);
    $w_frame_e3->pack(@pl);
    $w_frame_s3->pack(@pl);

    $w_frame_e1->insert(0, 'Initial value');
    $w_frame_e2->insert('end', 'This entry contains a long value, much too long to fit in the window at one time, so long in fact that you\'ll have to scan or scroll to see the end.');

} # end entry2

1;
