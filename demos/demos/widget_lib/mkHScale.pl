

sub mkHScale {

    # Create a top-level window that displays a horizontal scale.

    $mkHScale->destroy if Exists($mkHScale);
    $mkHScale = $top->Toplevel();
    my $w = $mkHScale;
    dpos $w;
    $w->title('Horizontal Scale Demonstration');
    $w->iconname('Scale');
    my $w_msg = $w->Label(-font => '-Adobe-times-medium-r-normal--*-180-*-*-*-*-*-*', -wraplength => '3i',
			   -justify => 'left', -text => 'An arrow and a horizontal scale are displayed below.  If you click ' .
			   'or drag mouse button 1 in the scale, you can change the width of the arrow.  Click the "OK" ' .
			   'button when you\'re finished.');
    my $w_frame = $w->Frame(-borderwidth => 10);
    my $w_ok = $w->Button(-text => 'OK', -width => 8, -command => [sub{shift->destroy}, $w]);
    $w_msg->pack(-side => 'top', -fill => 'x');
    $w_frame->pack(-side => 'top', -fill => 'x');
    $w_ok->pack(-side => 'top');

    $w_frame_canvas = $w_frame->Canvas(qw(-width 50 -height 50 -bd 0 -highlightthickness 0));
    $w_frame_canvas->create(qw(polygon 0 0 1 1 2 2 -fill DeepSkyBlue3 -tags poly));
    $w_frame_canvas->create(qw(line 0 0 1 1 2 2 0 0 -fill black -tags line));
    $w_frame_scale = $w_frame->Scale(qw(-orient horizontal -length 284 -from 0 -to 250 -tickinterval 50),
				-command => [\&setWidth, $w_frame_canvas]);
    $w_frame_canvas->pack(qw(-side top -expand yes -anchor s -fill x));
    $w_frame_scale->pack(qw(-side bottom -expand yes -anchor n));
    $w_frame_scale->set(75);

} # end mkHScale


sub setWidth {

    my($w, $width) = @_;

    $width += 21;
    my $x2 = $width - 30;
    $x2 = 21 if $x2 < 21;
    $w->coords('poly', 20, 15, 20, 35, $x2, 35, $x2, 45, $width, 25, $x2, 5, $x2, 15, 20, 15);
    $w->coords('line', 20, 15, 20, 35, $x2, 35, $x2, 45, $width, 25, $x2, 5, $x2, 15, 20, 15);

} # end setWidth


1;
