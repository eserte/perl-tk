# states.pl

sub states {

    # Create a top-level window that displays a listbox with the names of the
    # 50 states.

    my($demo) = @ARG;

    $STATES->destroy if Exists($STATES);
    $STATES = $mw->Toplevel;
    my $w = $STATES;
    dpos $w;
    $w->title('Listbox Demonstration (50 states)');
    $w->iconname('states');

    my $w_msg = $w->Label(
        -font       => $FONT,
        -justify    => 'left',
	-wraplength => '4i',
        -text       => 'A listbox containing the 50 states is displayed below, along with a scrollbar.  You can scan the list either using the scrollbar or by scanning.  To scan, press button 2 the widget and drag up or down.',
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

    my $w_frame = $w->Frame(-borderwidth => '.5c');
    $w_frame->pack(-side => 'top', -expand => 'yes', -fill => 'y');

    my $w_frame_scroll = $w_frame->Scrollbar;
    $w_frame_scroll->pack(-side => 'right', -fill => 'y');
    my $w_frame_list = $w_frame->Listbox(
        -yscrollcommand => ['set', $w_frame_scroll],
        -setgrid        => 1,
        -height         => 12,
    );
    $w_frame_scroll->configure(-command => ['yview', $w_frame_list]);
    $w_frame_list->pack(-side => 'left', -expand => 'yes', -fill => 'both');

    $w_frame_list->insert(0, qw(Alabama Alaska Arizona Arkansas California Colorado Connecticut Delaware Florida Georgia Hawaii Idaho Illinois Indiana Iowa Kansas Kentucky Louisiana Maine Maryland Massachusetts Michigan Minnesota Mississippi Missouri Montana Nebraska Nevada), 'New Hampshire', 'New Jersey', 'New Mexico', 'New York', 'North Carolina', 'North Dakota', qw( Ohio Oklahoma Oregon Pennsylvania), 'Rhode Island', 'South Carolina', 'South Dakota', qw(Tennessee Texas Utah Vermont Virginia Washington), 'West Virginia', 'Wisconsin', 'Wyoming');

} # end states

1;
