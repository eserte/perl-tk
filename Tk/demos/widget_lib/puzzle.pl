# puzzle.pl

sub puzzle_switch;

sub puzzle {

    # Create a top-level window containing a 15-puzzle game.

    my($demo) = @ARG;

    $PUZZLE->destroy if Exists($PUZZLE);
    $PUZZLE = $mw->Toplevel;
    my $w = $PUZZLE;
    dpos $w;
    $w->title('15-Puzzle Demonstration');
    $w->iconname('puzzle');

    my $w_msg = $w->Label(
        -font       => $FONT,
        -wraplength => '4i',
        -justify    => 'left',
        -text       => 'A 15-puzzle appears below as a collection of buttons.  Click on any of the pieces next to the space, and that piece will slide over the space.  Continue this until the pieces are arranged in numerical order from upper-left to lower-right.',
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

    # Special trick: select a darker color for the space by creating a
    # scrollbar widget and using its trough color.

    my $w_s = $mw->Scrollbar;
    my $w_frame = $w->Frame(
        -width       => 120,
        -height      => 120,
        -borderwidth => '2',
        -relief      => 'sunken',
        -background  => $w_s->cget(-troughcolor),
    );
    $w_frame->pack(-side => 'top', -padx => '1c', -pady => '1c');
    $w_s->destroy;

    @order = (3, 1, 6, 2, 5, 7, 15, 13, 4, 11, 8, 9, 14, 10, 12);
    for ($i=0; $i<15; $i++) {
	$num = $order[$i];
	$puzzle::xpos{$num} = ($i%4)*.25;
	$puzzle::ypos{$num} = (int($i/4))*.25;
	$w_frame_num = $w_frame->Button(
            -relief             => 'raised',
            -text               => $num,
            -highlightthickness => 0,
        );
	$w_frame_num->configure(
            -command => [\&puzzle_switch, $w_frame_num, $num],
        );
	$w_frame_num->place(
            -relx       => $puzzle::xpos{$num},
            -rely      => $puzzle::ypos{$num},
            -relwidth  => .25,
	    -relheight => .25,
        );
    } # forend all puzzle numbers
    $puzzle::xpos{'space'} = .75;
    $puzzle::ypos{'space'} = .75;

} # end puzzle


sub puzzle_switch {
    
    # Procedure invoked by buttons in the puzzle to resize the puzzle entries.

    my($w, $num) = @ARG;

    if (    (($puzzle::ypos{$num} >= ($puzzle::ypos{'space'} - .01)) &&
	     ($puzzle::ypos{$num} <= ($puzzle::ypos{'space'} + .01))
         &&  ($puzzle::xpos{$num} >= ($puzzle::xpos{'space'} - .26)) &&
	     ($puzzle::xpos{$num} <= ($puzzle::xpos{'space'} + .26)))
	 || (($puzzle::xpos{$num} >= ($puzzle::xpos{'space'} - .01)) &&
	     ($puzzle::xpos{$num} <= ($puzzle::xpos{'space'} + .01))
	 &&  ($puzzle::ypos{$num} >= ($puzzle::ypos{'space'} - .26)) &&
	     ($puzzle::ypos{$num} <= ($puzzle::ypos{'space'} + .26))) ) {
	my $tmp = $puzzle::xpos{'space'};
	$puzzle::xpos{'space'} = $puzzle::xpos{$num};
	$puzzle::xpos{$num} = $tmp;
	$tmp = $puzzle::ypos{'space'};
	$puzzle::ypos{'space'} =  $puzzle::ypos{$num};
	$puzzle::ypos{$num} = $tmp;
	$w->place(
            -relx => $puzzle::xpos{$num},
            -rely => $puzzle::ypos{$num},
        );
    }

} # end puzzle_switch

1;
