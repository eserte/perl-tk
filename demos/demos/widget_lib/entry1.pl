# entry1.pl

sub entry1 {

    # Create a top-level window that displays a bunch of entries.

    my($demo) = @ARG;

    $ENTRY1->destroy if Exists($ENTRY1);
    $ENTRY1 = $MW->Toplevel;
    my $w = $ENTRY1;
    dpos $w;
    $w->title('Entry Demonstration (no scrollbars)');
    $w->iconname('entry1');

    my $w_msg = $w->Label(
        -font       => $FONT,
        -wraplength => '5i',
        -justify    => 'left',
        -text       => 'Three different entries are displayed below.  You can add characters by pointing, clicking and typing.  The normal Motif editing characters are supported, along with many Emacs bindings.  For example, Backspace and Control-h delete the character to the left of the insertion cursor and Delete and Control-d delete the chararacter to the right of the insertion cursor.  For entries that are too large to fit in the window all at once, you can scan through the entries by dragging with mouse button2 pressed.',
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

    my(@pl) = (-side => 'top', -fill => 'both');
    my $w_e1 = $w->Entry(-relief => 'sunken');
    my $w_e2 = $w->Entry(-relief => 'sunken');
    my $w_e3 = $w->Entry(-relief => 'sunken');
    @pl = (-side => 'top', -padx => 10, -pady => 5, -fill => 'x');
    $w_e1->pack(@pl);
    $w_e2->pack(@pl);
    $w_e3->pack(@pl);

    $w_e1->insert(0, 'Initial value');
    $w_e2->insert('end', 'This entry contains a long value, much too long to fit in the window at one time, so long in fact that you\'ll have to scan or scroll to see the end.');

} # end entry1

1;
