

sub mkListbox {

    # Create a top-level window that displays a listbox with the names of the 50 states.

    $mkListbox->destroy if Exists($mkListbox);
    $mkListbox = $top->Toplevel();
    my $w = $mkListbox;
    dpos $w;
    $w->title('Listbox Demonstration (50 states)');
    $w->iconname('Listbox');
    $w->minsize(1, 1);

    my $w_msg = $w->Label(-font => '-Adobe-times-medium-r-normal--*-180-*-*-*-*-*-*', -justify => 'left',
			   -wraplength => '3.5i', -text => 'A listbox containing the 50 states is displayed below, along ' .
			   'with a scrollbar.  You can scan the list either using the scrollbar or by dragging in the ' .
			   'listbox window with button 2 pressed.  Click the "OK" button when you\'ve seen enough.');
    my $w_frame = $w->Frame(-borderwidth => 10);
    my $w_ok = $w->Button(-text => 'OK', -width => 8, -command => ['destroy', $w]);
    $w_msg->pack(-side => 'top');
    $w_frame->pack(-side => 'top', -expand => 'yes', -fill => 'y');
    $w_ok->pack(-side => 'bottom');

    my $w_frame_scroll = $w_frame->Scrollbar();
    my $w_frame_list = $w_frame->Listbox(-yscrollcommand => ['set', $w_frame_scroll], -setgrid => 1);
    $w_frame_scroll->configure(-command => ['yview', $w_frame_list]);
    $w_frame_scroll->pack(-side => 'right', -fill => 'y');
    $w_frame_list->pack(-side => 'left', -expand => 'yes', -fill => 'both');

    $w_frame_list->insert(0, qw(Alabama Alaska Arizona Arkansas California Colorado Connecticut Delaware Florida Georgia Hawaii
				Idaho Illinois Indiana Iowa Kansas Kentucky Louisiana Maine Maryland Massachusetts Michigan
				Minnesota Mississippi Missouri Montana Nebraska Nevada), 'New Hampshire', 'New Jersey',
			        'New Mexico', 'New York', 'North Carolina', 'North Dakota', qw( Ohio Oklahoma Oregon
 			        Pennsylvania), 'Rhode Island', 'South Carolina', 'South Dakota', qw(Tennessee Texas Utah
			        Vermont Virginia Washington), 'West Virginia', 'Wisconsin', 'Wyoming');

} # end mkListbox


1;
