

sub mkEntry2 {

   # Create a top-level window that displays a bunch of entries with scrollbars.

    $mkEntry2->destroy if Exists($mkEntry2);
    $mkEntry2 = $top->Toplevel();
    my $w = $mkEntry2;
    dpos $w;
    $w->title('Entry Demonstration');
    $w->iconname('Entries');
    my $w_msg = $w->Label(-font => '-Adobe-times-medium-r-normal--*-180-*-*-*-*-*-*', -wraplength => '5i',
			   -justify => 'left', -text => 'Three different entries are displayed below, with a scrollbar for ' .
			   'each entry.  You can add characters by pointing, clicking, and typing.  You can delete by ' .
			   'selecting and typing Backspace, Delete, or Control-X.  Backspace and Control-h erase the ' .
			   'character to the left of the insertion cursor, Delete and Control-d delete the chararacter ' .
			   'to the right of the insertion cursor, Control-W erases the word to the left of the insertion ' .
			   'cursor, and Meta-d deletes the word to the right of the insertion cursor.  For entries that are ' .
			   'too large to fit in the window all at once, you can scan through the entries using the ' .
			   'scrollbars, or by dragging with mouse button 2 pressed.  Click the "OK" button when you\'ve ' .
			   'seen enough.');
    my $w_frame = $w->Frame(-borderwidth => '10');
    my $w_ok = $w->Button(-text => 'OK', -width => 8, -command => ['destroy', $w]);
    my (@pl) = (-side => 'top', -fill => 'both');
    $w_msg->pack(@pl);
    $w_frame->pack(@pl);
    $w_ok->pack(-side => 'top');

    my $w_frame_e1 = $w_frame->Entry(-relief => 'sunken');
    my $w_frame_s1 = $w_frame->Scrollbar(-relief => 'sunken', -orient => 'horiz', -command => ['xview',$w_frame_e1]);
    $w_frame_e1->configure(-xscrollcommand => ['set', $w_frame_s1]);
    my $w_frame_f1 = $w_frame->Frame(-width => 20, -height => 10);
    my $w_frame_e2 = $w_frame->Entry(-relief => 'sunken');
    my $w_frame_s2 = $w_frame->Scrollbar(-relief => 'sunken', -orient => 'horiz', -command => ['xview', $w_frame_e2]);
    $w_frame_e2->configure(-xscrollcommand => ['set', $w_frame_s2]);
    my $w_frame_f2 = $w_frame->Frame(-width => 20, -height => 10);
    my $w_frame_e3 = $w_frame->Entry(-relief => 'sunken');
    my $w_frame_s3 = $w_frame->Scrollbar(-relief => 'sunken', -orient => 'horiz', -command => ['xview', $w_frame_e3]);
    $w_frame_e3->configure(-xscrollcommand => ['set', $w_frame_s3]);

    @pl = (-side => 'top', -fill => 'x');
    $w_frame_e1->pack(@pl);
    $w_frame_s1->pack(@pl);
    $w_frame_f1->pack(@pl);
    $w_frame_e2->pack(@pl);
    $w_frame_s2->pack(@pl);
    $w_frame_f2->pack(@pl);
    $w_frame_e3->pack(@pl);
    $w_frame_s3->pack(@pl);

    $w_frame_e1->insert(0, "Initial value");
    $w_frame_e2->insert('end', "This entry contains a long value, much too long ");
    $w_frame_e2->insert('end', "to fit in the window at one time, so long in fact ");
    $w_frame_e2->insert('end', "that you'll have to scan or scroll to see the end.");

} # end mkEntry2


1;
