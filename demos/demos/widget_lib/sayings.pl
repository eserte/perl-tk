# sayings.pl

sub sayings {

    # Create a top-level window containing a listbox with a bunch of
    # well-known sayings.  The listbox can be scrolled or scanned in
    # two dimensions.

    my($demo) = @ARG;

    $SAYINGS->destroy if Exists($SAYINGS);
    $SAYINGS = $MW->Toplevel;
    my $w = $SAYINGS;
    dpos $w;
    $w->title('Listbox Demonstration (well-known sayings)');
    $w->iconname('sayings');

    my $w_msg = $w->Label(
        -font       => $FONT,
        -wraplength => '4i',
        -justify    => 'left',
        -text       => 'The listbox below contains a collection of well-known sayings.  You can scan the list using either of the scrollbars or by dragging in the listbox window with button 2 pressed.',
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

    my $w_frame = $w->Frame(-borderwidth => 10);
    $w_frame->pack(-side => 'top', -expand => 'yes', -fill => 'y');

    my $w_frame_yscroll = $w_frame->Scrollbar;
    $w_frame_yscroll->pack(-side => 'right', -fill => 'y');
    my $w_frame_xscroll = $w_frame->Scrollbar(-orient => 'horizontal');
    $w_frame_xscroll->pack(-side => 'bottom', -fill => 'x');
    my $w_frame_list = $w_frame->Listbox(
        -width          => 20,
        -height         => 10,
        -yscrollcommand => [$w_frame_yscroll => 'set'],
        -xscrollcommand => [$w_frame_xscroll => 'set'],
        -setgrid        => '1',
    );
    $w_frame_list->pack(-expand => 'yes', -fill => 'y');
    $w_frame_yscroll->configure(-command => [$w_frame_list => 'yview']);
    $w_frame_xscroll->configure(-command => [$w_frame_list => 'xview']);

    $w_frame_list->insert(0, 'Waste not, want not', 'Early to bed and
			  early to rise makes a man healthy, wealthy,
			  and wise', 'Ask not what your country can do
			  for you, ask what you can do for your
			  country', 'I shall return', 'NOT', 'A
			  picture is worth a thousand words', 'User
			  interfaces are hard to build', 'Thou shalt
			  not steal', 'A penny for your thoughts',
			  'Fool me once, shame on you; fool me twice,
			  shame on me', 'Every cloud has a silver
			  lining', 'Where there\'s smoke there\'s
			  fire', 'It takes one to know one',
			  'Curiosity killed the cat', 'Take this job
			  and shove it', 'Up a creek without a
			  paddle', 'I\'m mad as hell and I\'m not
			  going to take it any more', 'An apple a day
			  keeps the doctor away', 'Don\'t look a gift
			  horse in the mouth');

} # end sayings

1;
