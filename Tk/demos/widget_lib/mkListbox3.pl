

sub mkListbox3 {

    # Create a top-level window containing a listbox with a bunch of well-known sayings.  The listbox can be scrolled or
    # scanned in two dimensions.

    $mkListbox3->destroy if Exists($mkListbox3);
    $mkListbox3 = $top->Toplevel();
    my $w = $mkListbox3;
    dpos $w;
    $w->title('Listbox Demonstration (well-known sayings)');
    $w->iconname('Listbox');
    $w->minsize('1', '1');
    my $w_msg = $w->Label(-font => '-Adobe-times-medium-r-normal--*-180-*-*-*-*-*-*', -wraplength => '3.5i',
			   -justify => 'left', -text => 'The listbox below contains a collection of well-known sayings.  You ' .
			   'can scan the list using either of the scrollbars or by dragging in the listbox window with ' .
			   'button 2 pressed.  Click the "OK" button when you\'re done.');
    my $w_frame = $w->Frame(-borderwidth => 10);
    my $w_ok = $w->Button(-text => 'OK', -width => 8, -command => ['destroy', $w]);
    $w_msg->pack(-side => 'top');
    $w_ok->pack(-side => 'bottom');
    $w_frame->pack(-side => 'top', -expand => 'yes', -fill => 'y');

    my $w_frame_yscroll = $w_frame->Scrollbar();
    my $w_frame_xscroll = $w_frame->Scrollbar(-orient => 'horizontal');
    my $w_frame_list = $w_frame->Listbox(-width => 20, -height => 10, -yscrollcommand => ['set', $w_frame_yscroll],
				    -xscrollcommand => ['set', $w_frame_xscroll], -setgrid => '1');
    $w_frame_yscroll->configure(-command => ['yview', $w_frame_list]);
    $w_frame_xscroll->configure(-command => ['xview', $w_frame_list]);
    $w_frame_yscroll->pack(-side => 'right', -fill => 'y');
    $w_frame_xscroll->pack(-side => 'bottom', -fill => 'x');
    $w_frame_list->pack(-expand => 'yes', -fill => 'y');

    $w_frame_list->insert(0, 'Waste not, want not', 'Early to bed and early to rise makes a man healthy, wealthy, and wise',
			  'Ask not what your country can do for you, ask what you can do for your country', 'I shall return',
			  'NOT', 'A picture is worth a thousand words', 'User interfaces are hard to build',
			  'Thou shalt not steal', 'A penny for your thoughts',
			  'Fool me once, shame on you;  fool me twice, shame on me', 'Every cloud has a silver lining',
			  'Where there\'s smoke there\'s fire', 'It takes one to know one', 'Curiosity killed the cat',
			  'Take this job and shove it', 'Up a creek without a paddle',
			  'I\'m mad as hell and I\'m not going to take it any more', 'An apple a day keeps the doctor away',
			  'Don\'t look a gift horse in the mouth');

} # end mkListbox3


1;
