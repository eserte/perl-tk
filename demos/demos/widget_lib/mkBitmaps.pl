

# use subs qw(bitmapRow);


sub bitmapRow  {

    # The procedure below creates a new row of bitmaps in a window.  Its arguments are:
    #
    # w -	The window reference that is to contain the row.
    # args -	The names of one or more bitmaps, which will be displayed in frame $w

    my($w, @names) = @_;
    my($bitmap, $wr, $wr_bit, $wr_bit_bitmap, $wr_bit_label);

    $wr = $w->Frame();
    $wr->pack(-side => 'top', -fill => 'both');

    foreach $bitmap (@names) {
	$wr_bit = $wr->Frame();
	$wr_bit->pack(-side => 'left', -fill => 'both', -pady => '.25c', -padx => '.25c');
	$wr_bit_bitmap = $wr_bit->Label(-bitmap => $bitmap);
	$wr_bit_label = $wr_bit->Label(-text => $bitmap, -width => 9);
	$wr_bit_label->pack(-side => 'bottom');
	$wr_bit_bitmap->pack(-side => 'bottom');
    }

} # end bitmapRow

sub mkBitmaps  {

    # Create a top-level window that displays all of Tk's built-in bitmaps.

    $mkBitmaps->destroy if Exists($mkBitmaps);
    $mkBitmaps = $top->Toplevel();
    my $w = $mkBitmaps;
    dpos $w;
    $w->title('Bitmap Demonstration');
    $w->iconname('Bitmaps');

    my $w_msg = $w->Label(-font => '-Adobe-times-medium-r-normal--*-180-*-*-*-*-*-*', -wraplength => '4i',
			   -justify => 'left', -text => 'This window displays all of Tk\'s built-in bitmaps, along with the ' .
			   'names you can use for them in Perl scripts.  Click the "OK" button when you\'ve seen enough.');
    my $w_frame = $w->Frame();
    bitmapRow $w_frame, qw(error gray25 gray50 hourglass);
    bitmapRow $w_frame, qw(info question questhead warning);
    my $w_ok = $w->Button(-text => 'OK', -width => 8, -command => ['destroy', $w]);
    $w_msg->pack(-side => 'top', -anchor => 'center');
    $w_frame->pack(-side => 'top', -expand => 'yes', -fill => 'both');
    $w_ok->pack(-side => 'bottom');

} # end mkBitmaps





1;
