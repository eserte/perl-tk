# plot.pl

BEGIN {unshift @INC, Tk->findINC('demos/widget_lib')};
require Plot;

sub plot {

    # Create a top-level window containing a canvas displaying a simple 
    # graph with data points that can be dragged with the pointing device.

    my($demo) = @ARG;

    $PLOT->destroy if Exists($PLOT);
    $PLOT = $MW->Toplevel;
    my $w = $PLOT;
    dpos $w;
    $w->title('Plot Demonstration');
    $w->iconname('plot');

    my $w_msg = $w->Label(
        -font       => $FONT,
        -wraplength => '4i',
        -justify    => 'left',
        -text       => "This window displays a canvas widget containing a simple 2-dimensional plot.  You can doctor the data by dragging any of the points with mouse button 1.\n\nYou can also select a printable area with the mouse button 2.",
    );
    $w_msg->pack;

    my $w_buttons = $w->Frame;
    $w_buttons->pack(qw(-side bottom -expand y -fill x -pady 2m));
    my $w_dismiss = $w_buttons->Button(
        -text    => 'Dismiss',
        -command => [$w => 'destroy'],
    );
    $w_dismiss->pack(qw(-side left -expand 1));
    my $w_see = $w_buttons->Button(
        -text    => 'See Code',
        -command => [\&seeCode, $demo],
    );
    $w_see->pack(qw(-side left -expand 1));

    my $c = $w->Plot(
        -title_color        => 'Brown',
        -inactive_highlight => 'Skyblue2',
        -active_highlight   => 'red',
    );
    $c->pack(-fill => 'x');
  
} # end plot

1;
