

sub mkVScale {

# Create a top-level window that displays a vertical scale.

    $mkVScale->destroy if Exists($mkVScale);
    $mkVScale = $top->Toplevel();
    my $w = $mkVScale;
    dpos $w;
    $w->title('Vertical Scale Demonstration');
    $w->iconname('Scale');
    my $w_msg = $w->Label(-font => '-Adobe-times-medium-r-normal--*-180*-*-*-*-*-*-*', -wraplength => '4i',
			   -justify => 'left', -text => 'An arrow and a vertical scale are displayed below.  If you click ' .
			   'or drag mouse button 1 in the scale, you can change the height of the arrow.  Click the "OK" ' .
			   'button when you\'re finished.');
    my $w_frame = $w->Frame(-borderwidth => 10);
    my $w_ok = $w->Button(-text => 'OK', -width => 8, -command => ['destroy', $w]);
    $w_msg->pack();
    $w_frame->pack();
    $w_ok->pack();

    my $w_frame_canvas = $w_frame->Canvas(qw(-width 50 -height 50 -bd 0 -highlightthickness 0));
    $w_frame_canvas->create(qw(polygon 0 0 1 1 2 2 -fill SeaGreen3 -tags poly));
    $w_frame_canvas->create(qw(line 0 0 1 1 2 2 0 0 -fill black -tags line));
    my $w_frame_scale = $w_frame->Scale(-orient => 'vertical', '-length' => 284, -from => 0, -to => 250, -tickinterval => 50,
				   -command => [\&setHeight, $w_frame_canvas]);
    $w_frame_scale->pack(-side => 'left', -anchor => 'ne');
    $w_frame_canvas->pack(-side => 'left', -anchor => 'nw', -fill => 'y');
    $w_frame_scale->set(75);

} # end mkVScale


sub setHeight {

    my($w, $height) = @_;

    $height += 21;
    $y2 = $height - 30;
    $y2 = 21 if $y2 < 21;
    $w->coords('poly', 15, 20, 35, 20, 35, $y2, 45, $y2, 25, $height, 5, $y2, 15, $y2, 15, 20);
    $w->coords('line', 15, 20, 35, 20, 35, $y2, 45, $y2, 25, $height, 5, $y2, 15, $y2, 15, 20);

} # end setHeight


1;
