# puzzle.pl

sub puzzle_switch;

sub puzzle {

    # Create a top-level window containing a 15-puzzle game.

    my($demo) = @ARG;

    $PUZZLE->destroy if Exists($PUZZLE);
    $PUZZLE = $MW->Toplevel;
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
    $w_msg->pack;

    my $w_buttons = $w->Frame;
    $w_buttons->pack(qw(-side bottom -fill x -pady 2m));
    my $w_dismiss = $w_buttons->Button(
        -text    => 'Dismiss',
        -command => [$w => 'destroy'],
    );
    $w_dismiss->pack(qw(-side left -expand 1));
    my $w_see = $w_buttons->Button(
        -text    => 'See Code',
        -command => [\&see_code, $demo],
    );
    $w_see->pack(qw(-side left -expand 1));

    # Special trick: select a darker color for the space by creating a
    # scrollbar widget and using its trough color.

    my $w_s = $MW->Scrollbar;
    my $w_frame = $w->Frame(
        -width       => 120,
        -height      => 120,
        -borderwidth => '2',
        -relief      => 'sunken',
        -background  => $w_s->cget(-troughcolor),
    );
    $w_frame->pack(-side => 'top', -padx => '1c', -pady => '1c');
    $w_s->destroy;

    my(@order) = (3, 1, 6, 2, 5, 7, 15, 13, 4, 11, 8, 9, 14, 10, 12);
    my %xpos = ();
    my %ypos = ();

    my($i, $num, $w_frame_num);
    for ($i=0; $i<15; $i++) {
	$num = $order[$i];
	$xpos{$num} = ($i%4) * 0.25;
	$ypos{$num} = (int($i/4)) * 0.25;
	$w_frame_num = $w_frame->Button(
            -relief             => 'raised',
            -text               => $num,
            -highlightthickness => 0,
        );
	$w_frame_num->configure(
            -command => [\&puzzle_switch, $w_frame_num, $num, \%xpos, \%ypos],
        );
	$w_frame_num->place(
            -relx      => $xpos{$num},
            -rely      => $ypos{$num},
            -relwidth  => 0.25,
	    -relheight => 0.25,
        );
    } # forend all puzzle numbers
    $xpos{'space'} = 0.75;
    $ypos{'space'} = 0.75;

} # end puzzle

sub puzzle_switch {
    
    # Procedure invoked by buttons in the puzzle to resize the puzzle entries.

    my($w, $num, $xpos, $ypos) = @ARG;

    if (    (($ypos->{$num} >= ($ypos->{'space'} - 0.01)) &&
	     ($ypos->{$num} <= ($ypos->{'space'} + 0.01))
         &&  ($xpos->{$num} >= ($xpos->{'space'} - 0.26)) &&
	     ($xpos->{$num} <= ($xpos->{'space'} + 0.26)))
	 || (($xpos->{$num} >= ($xpos->{'space'} - 0.01)) &&
	     ($xpos->{$num} <= ($xpos->{'space'} + 0.01))
	 &&  ($ypos->{$num} >= ($ypos->{'space'} - 0.26)) &&
	     ($ypos->{$num} <= ($ypos->{'space'} + 0.26))) ) {
	my $tmp = $xpos->{'space'};
	$xpos->{'space'} = $xpos->{$num};
	$xpos->{$num} = $tmp;
	$tmp = $ypos->{'space'};
	$ypos->{'space'} =  $ypos->{$num};
	$ypos->{$num} = $tmp;
	$w->place(-relx => $xpos->{$num}, -rely => $ypos->{$num});
    }

} # end puzzle_switch

1;
