

sub mkIcon {

    # Create a top-level window that displays a bunch of iconic buttons.

    $mkIcon->destroy if Exists($mkIcon);
    $mkIcon = $top->Toplevel();
    my $w = $mkIcon;
    dpos $w;
    $w->title('Iconic Button Demonstration');
    $w->iconname('Icons');
    $w->Bitmap('flagup', -file => Tk->findINC('demos/images/flagup'),
		  -maskfile => Tk->findINC('demos/images/flagup'));
    $w->Bitmap('flagdown', -file => Tk->findINC('demos/images/flagdown'),
		  -maskfile => Tk->findINC('demos/images/flagdown'));
    my $w_msg = $w->Label(-font => '-Adobe-times-medium-r-normal--*-180-*-*-*-*-*-*', -wraplength => '4.5i',
			   -justify => 'left', -text => 'This window shows three ways of using bitmaps or images in ' .
			   'radiobuttons and checkbuttons.  On the left are two radiobuttons, each of which displays a ' .
			   'bitmap and an indicator.  In the middle is a checkbutton that displays a different image ' .
			   'depending on whether it is selected or not.  On the right is a checkbutton that displays a ' .
			   'single bitmap but changes its background color to indicate whether or not it is selected.  ' .
			   'Click the "OK" button when you\'re done.');
    my $w_frame = $w->Frame(-borderwidth => '10');
    my $w_ok = $w->Button(-text => 'OK', -command => ['destroy', $w], -width => '8');
    my @pl = (-side => 'top');
    $w_msg->pack(@pl);
    $w_frame->pack(@pl);
    $w_ok->pack(@pl);

    my $w_frame_b1 = $w_frame->Checkbutton(-image => 'flagdown', -selectimage => 'flagup', -indicatoron => 0,
				      -selectcolor => 'bisque1', -activebackground => 'bisque1');
    my $w_frame_b2 = $w_frame->Checkbutton(-bitmap => '@'.Tk->findINC('demos/images/letters'), -indicatoron => 0,
				      -selectcolor => '#efbd9b');
    my $w_frame_left = $w_frame->Frame();
    @pl = (-side => 'left', -expand => 'yes', -padx => '5m');
    $w_frame_left->pack(@pl);
    $w_frame_b1->pack(@pl);
    $w_frame_b2->pack(@pl);

    $letters = '';
    my $w_frame_left_b3 = $w_frame_left->Radiobutton(-bitmap => '@'.Tk->findINC('demos/images/letters'), -variable => \$letters,
					   -value => 'full');
    my $w_frame_left_b4 = $w_frame_left->Radiobutton(-bitmap => '@'.Tk->findINC('demos/images/noletters'), -variable => \$letters,
					   -value => 'empty');
    @pl = (-side => 'top', -expand => 'yes');
    $w_frame_left_b3->pack(@pl);
    $w_frame_left_b4->pack(@pl);

} # end mkIcon


1;
