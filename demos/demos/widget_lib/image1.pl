# image1.pl

sub image1 {

    # This demonstration script displays two image widgets.

    my($demo) = @ARG;

    $IMAGE1->destroy if Exists($IMAGE1);
    $IMAGE1 = $MW->Toplevel;
    my $w = $IMAGE1;
    dpos $w;
    $w->title('Image Demonstration #1');
    $w->iconname('image1');

    my $w_msg = $w->Label(
        -font       => $FONT,
        -wraplength => '4i',
        -justify    => 'left',
        -text       => 'This demonstration displays two images, each in a separate label widget.',
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

    $w->Photo('image1a', -file => Tk->findINC('demos/images/earth.gif'));
    my $w_l1 = $w->Label(-image => 'image1a');
    $w_l1->pack(-side => 'top', -padx => '.5m', -pady => '.5m');

    $w->Photo('image1b', -file => Tk->findINC('demos/images/earthris.gif'));
    my $w_l2 = $w->Label(-image => 'image1b');
    $w_l2->pack(-side => 'top', -padx => '.5m', -pady => '.5m');

} # end image1

1;


