# vscale.pl

sub vscale_height;

sub vscale {

    # Create a top-level window that displays a vertical scale.

    my($demo) = @ARG;

    $VSCALE->destroy if Exists($VSCALE);
    $VSCALE = $MW->Toplevel;
    my $w = $VSCALE;
    dpos $w;
    $w->title('Vertical Scale Demonstration');
    $w->iconname('vscale');

    my $w_msg = $w->Label(
        -font       => $FONT,
        -wraplength => '3.5i',
        -justify    => 'left',
        -text       => 'An arrow and a vertical scale are displayed below.  If you click or drag mouse button 1 in the scale, you can change the size of the arrow.',
    );
    $w_msg->pack(-padx => '.5c');

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

    my $w_frame = $w->Frame(-borderwidth => 10);
    $w_frame->pack;

    my $w_frame_canvas = $w_frame->Canvas(
        qw(-width 50 -height 50 -bd 0 -highlightthickness 0),
    );
    $w_frame_canvas->create(
        qw(polygon 0 0 1 1 2 2 -fill SeaGreen3 -tags poly),
    );
    $w_frame_canvas->create(qw(line 0 0 1 1 2 2 0 0 -fill black -tags line));
    my $w_frame_scale = $w_frame->Scale(
        -orient       => 'vertical',
        '-length'     => 284,
        -from         => 0, 
        -to           => 250,
        -tickinterval => 50,
        -command      => [\&vscale_height, $w_frame_canvas],
    );
    $w_frame_scale->pack(-side => 'left', -anchor => 'ne');
    $w_frame_canvas->pack(-side => 'left', -anchor => 'nw', -fill => 'y');
    $w_frame_scale->set(75);

} # end vscale

sub vscale_height {

    my($w, $height) = @ARG;

    $height += 21;
    my $y2 = $height - 30;
    $y2 = 21 if $y2 < 21;
    $w->coords('poly', 15, 20, 35, 20, 35, $y2, 45, $y2, 25, $height, 5, $y2,
	       15, $y2, 15, 20);
    $w->coords('line', 15, 20, 35, 20, 35, $y2, 45, $y2, 25, $height, 5, $y2,
	       15, $y2, 15, 20);

} # end vscale_height

1;
