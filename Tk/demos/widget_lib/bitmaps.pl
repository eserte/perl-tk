# bitmaps.pl

sub bitmapRow;
sub mkBitmaps;

sub bitmaps {

    # Create a top-level window that displays all of Tk's built-in bitmaps.

    my($demo) = @ARG;

    $BITMAPS->destroy if Exists($BITMAPS);
    $BITMAPS = $mw->Toplevel;
    my $w = $BITMAPS;
    dpos $w;
    $w->title('Bitmap Demonstration');
    $w->iconname('bitmaps');

    my $w_msg = $w->Label(
        -font       => $FONT,
        -wraplength => '4i', 
        -justify    => 'left',
        -text       => 'This window displays all of Tk\'s built-in bitmaps, ' .
		       'along with the names you can use for them in Perl ' .
                       'scripts.');
    $w_msg->pack(-side => 'top', -anchor => 'center');

    my $w_buttons = $w->Frame;
    $w_buttons->pack(
        -side   => 'bottom',
        -expand => 'y',
        -fill   => 'x',
        -pady   => '2m',
    );
    my $w_dismiss = $w_buttons->Button(
        -text    => 'Dismiss',
        -command => ['destroy', $w],
    );
    $w_dismiss->pack(-side => 'left', -expand => 1);
    my $w_see = $w_buttons->Button(
        -text    => 'See Code',
        -command => [\&seeCode, $demo],
    );
    $w_see->pack(-side => 'left', -expand => 1);

    my $w_frame = $w->Frame;
    $w_frame->pack(-side => 'top', -expand => 'yes', -fill => 'both');
    bitmapRow $w_frame, qw(error gray25 gray50 hourglass);
    bitmapRow $w_frame, qw(info question questhead warning);

} # end bitmaps

sub bitmapRow  {
 
    # The procedure below creates a new row of bitmaps in a window.  Its
    # arguments are:

    my($w, @names) = @ARG;

    my($bitmap, $wr, $wr_bit, $wr_bit_bitmap, $wr_bit_label);

    $wr = $w->Frame;
    $wr->pack(-side => 'top', -fill => 'both');

    foreach $bitmap (@names) {
	$wr_bit = $wr->Frame;
	$wr_bit->pack(-side => 'left', -fill => 'both', -pady => '.25c',
		      -padx => '.25c');
	$wr_bit_bitmap = $wr_bit->Label('-bitmap' => $bitmap);
	$wr_bit_label = $wr_bit->Label(-text => $bitmap, -width => 9);
	$wr_bit_label->pack(-side => 'bottom');
	$wr_bit_bitmap->pack(-side => 'bottom');
    }

} # end bitmapRow

1;
