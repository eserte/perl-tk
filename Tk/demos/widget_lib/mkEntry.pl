

sub mkEntry {

    # Create a top-level window that displays a bunch of entries.

    $mkEntry->destroy if Exists($mkEntry);
    $mkEntry = $top->Toplevel();
    my $w = $mkEntry;
    dpos $w;
    $w->title('Entry Demonstration');
    $w->iconname('Entries');
    my $w_msg = $w->Label(-font => '-Adobe-times-medium-r-normal--*-180-*-*-*-*-*-*', -wraplength => '5i',
			     -justify => 'left', -text => 'Three different entries are displayed below.  You can add ' .
			     'characters by pointing, clicking and typing.  You can delete by selecting and typing ' .
			     'Backspace, Delete, or Control-X.  Backspace and Control-h erase the character to the left ' .
			     'of the insertion cursor, Delete and Control-d delete the chararacter to the right of the ' .
			     'insertion cursor, Control-W erases the word to the left of the insertion cursor, and Meta-d ' .
			     'deletes the word to the right of the insertion cursor.  For entries that are too large to ' .
			     'fit in the window all at once, you can scan through the entries by dragging with mouse button ' .
			     '2 pressed.  Click the "OK" button when you\'ve seen enough.');
    my $w_frame = $w->Frame(-borderwidth => 10);
    my $w_ok = $w->Button(-text => 'OK', -width => 8, -command => ['destroy', $w]);
    my(@pl) = (-side => 'top', -fill => 'both');
    $w_msg->pack(@pl);
    $w_frame->pack(@pl);
    $w_ok->pack(-side => 'top');

    my $w_frame_e1 = $w_frame->Entry(-relief => 'sunken');
    my $w_frame_e2 = $w_frame->Entry(-relief => 'sunken');
    my $w_frame_e3 = $w_frame->Entry(-relief => 'sunken');
    @pl = (-side => 'top', -pady => 5, -fill => 'x');
    $w_frame_e1->pack(@pl);
    $w_frame_e2->pack(@pl);
    $w_frame_e3->pack(@pl);

    $w_frame_e1->insert(0, 'Initial value');
    $w_frame_e2->insert('end', 'This entry contains a long value, much too long ');
    $w_frame_e2->insert('end', 'to fit in the window at one time, so long in fact ');
    $w_frame_e2->insert('end', 'that you\'ll have to scan or scroll to see the end.');

} # end mkEntry


1;
