# icon.pl

sub icon {

    # Create a top-level window that displays a bunch of iconic buttons.

    my($demo) = @ARG;

    $ICON->destroy if Exists($ICON);
    $ICON = $MW->Toplevel;
    my $w = $ICON;
    dpos $w;
    $w->title('Iconic Button Demonstration');
    $w->iconname('icon');

    my $w_msg = $w->Label(
        -font       => $FONT,
        -wraplength => '5i',
        -justify    => 'left',
        -text       => 'This window shows three ways of using bitmaps or images in radiobuttons and checkbuttons.  On the left are two radiobuttons, each of which displays a bitmap and an indicator.  In the middle is a checkbutton that displays a different image depending on whether it is selected or not.  On the right is a checkbutton that displays a single bitmap but changes its background color to indicate whether or not it is selected.',
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

    $w->Bitmap('flagup',
        -file     => Tk->findINC('demos/images/flagup'),
	-maskfile => Tk->findINC('demos/images/flagup'),
    );
    $w->Bitmap('flagdown',
        -file     => Tk->findINC('demos/images/flagdown'),
	-maskfile => Tk->findINC('demos/images/flagdown'),
    );

    my $w_frame = $w->Frame(-borderwidth => '10');
    $w_frame->pack(-side => 'top');

    my(@pl) = (-side => 'left', -expand => 'yes', -padx => '5m');
    my $w_frame_left = $w_frame->Frame;
    $w_frame_left->pack(@pl);

    my $w_frame_b1 = $w_frame->Checkbutton(
        -image            => 'flagdown',
        -selectimage      => 'flagup',
        -indicatoron      => 0,
    );
    $w_frame_b1->pack(@pl);
    $w_frame_b1->configure(-selectcolor => $w_frame_b1->cget(-background));
    my $w_frame_b2 = $w_frame->Checkbutton(
        -bitmap      => '@'.Tk->findINC('demos/images/letters'),
        -indicatoron => 0,
	-selectcolor => 'SeaGreen1',
    );
    $w_frame_b2->pack(@pl);

    my $letters = '';
    @pl = (-side => 'top', -expand => 'yes');
    my $w_frame_left_b3 = $w_frame_left->Radiobutton(
        -bitmap   => '@'.Tk->findINC('demos/images/letters'),
        -variable => \$letters,
        -value    => 'full',
    );
    $w_frame_left_b3->pack(@pl);
    my $w_frame_left_b4 = $w_frame_left->Radiobutton(
        -bitmap   => '@'.Tk->findINC('demos/images/noletters'),
        -variable => \$letters,
        -value    => 'empty',
    );
    $w_frame_left_b4->pack(@pl);

} # end icon

1;
