

sub mkPuzzle {

    # Create a top-level window containing a 15-puzzle game.

    $mkPuzzle->destroy if Exists($mkPuzzle);
    $mkPuzzle = $top->Toplevel();
    my $w = $mkPuzzle;
    dpos $w;
    $w->title('15-Puzzle Demonstration');
    $w->iconname('15-Puzzle');

    my $w_msg = $w->Message(-font => '-Adobe-times-medium-r-normal--*-180-*-*-*-*-*-*', -aspect => '300', -text =>
			     'A 15-puzzle appears below as a collection of buttons.  Click on any of the pieces next to ' .
			     'the space, and that piece will slide over the space.  Continue this until the pieces are ' .
			     'arranged in numerical order from upper-left to lower-right.  Click the "OK" button when ' .
			     'you\'ve finished playing.');
    my $w_frame = $w->Frame(-width => 120, -height => 120, -borderwidth => '2', -relief => 'sunken', -background => 'Bisque3');
    my $w_ok = $w->Button(-text => 'OK', -width => 8, -command => ['destroy', $w]);
    $w_msg->pack(-side => 'top');
    $w_frame->pack(-side => 'top', -padx => '5', -pady => '5');
    $w_ok->pack(-side => 'bottom');

    @order = (3, 1, 6, 2, 5, 7, 15, 13, 4, 11, 8, 9, 14, 10, 12);
    for ($i=0; $i<15; $i++) {
	$num = $order[$i];
	$mkPuzzle::xpos{$num} = ($i%4)*.25;
	$mkPuzzle::ypos{$num} = (int($i/4))*.25;
	$w_frame_num = $w_frame->Button(-relief => 'raised', -text => $num, -highlightthickness => 0);
	$w_frame_num->configure(-command => [sub {&puzzle_switch}, $w_frame_num, $num]);
	$w_frame_num->place(-relx => $mkPuzzle::xpos{$num}, -rely => $mkPuzzle::ypos{$num}, -relwidth => .25,
			    -relheight => .25);
    }
    $mkPuzzle::xpos{'space'} = .75;
    $mkPuzzle::ypos{'space'} = .75;

} # end mkPuzzle


sub puzzle_switch {

    # Procedure invoked by buttons in the puzzle to resize the puzzle entries.

    my($w, $num) = @_;

    if (    (($mkPuzzle::ypos{$num} >= ($mkPuzzle::ypos{'space'} - .01)) &&
	     ($mkPuzzle::ypos{$num} <= ($mkPuzzle::ypos{'space'} + .01))
         &&  ($mkPuzzle::xpos{$num} >= ($mkPuzzle::xpos{'space'} - .26)) &&
	     ($mkPuzzle::xpos{$num} <= ($mkPuzzle::xpos{'space'} + .26)))
	 || (($mkPuzzle::xpos{$num} >= ($mkPuzzle::xpos{'space'} - .01)) &&
	     ($mkPuzzle::xpos{$num} <= ($mkPuzzle::xpos{'space'} + .01))
	 &&  ($mkPuzzle::ypos{$num} >= ($mkPuzzle::ypos{'space'} - .26)) &&
	     ($mkPuzzle::ypos{$num} <= ($mkPuzzle::ypos{'space'} + .26))) ) {
	my $tmp = $mkPuzzle::xpos{'space'};
	$mkPuzzle::xpos{'space'} = $mkPuzzle::xpos{$num};
	$mkPuzzle::xpos{$num} = $tmp;
	$tmp = $mkPuzzle::ypos{'space'};
	$mkPuzzle::ypos{'space'} =  $mkPuzzle::ypos{$num};
	$mkPuzzle::ypos{$num} = $tmp;
	$w->place(-relx => $mkPuzzle::xpos{$num}, -rely => $mkPuzzle::ypos{$num});
    }

} # end puzzle_switch


1;
