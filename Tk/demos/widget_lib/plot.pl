# plot.pl

sub plot_down;
sub plot_move;
sub area_down;
sub area_move;
sub area_save;

$plot::plot{'lastX'} = 0;
$plot::plot{'lastY'} = 0;
$plot::plot{'areaX2'} = -1;

sub plot {

    # Create a top-level window containing a canvas displaying a simple 
    # graph with data points that can be dragged with the pointing device.

    my($demo) = @ARG;

    $PLOT->destroy if Exists($PLOT);
    $PLOT = $mw->Toplevel;
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
    $w_msg->pack(-side => 'top');

    my $w_buttons = $w->Frame;
    $w_buttons->pack(qw( -side bottom -expand y -fill x -pady 2m));
    my $w_dismiss = $w_buttons->Button(
        -text    => 'Dismiss',
        -command => ['destroy', $w],
    );
    $w_dismiss->pack(qw(-side left -expand 1));

    my $c = $w->Canvas(-relief => 'raised', -width => '450', -height => '300');
    $c->pack(-side => 'top', -fill => 'x');

    my $w_print = $w_buttons->Button(
        -text    => 'Print in PostScript Format',
        -command => [\&area_save, $c],
    );
    $w_print->pack(qw(-side left -expand 1));
    my $w_see = $w_buttons->Button(
        -text    => 'See Code',
        -command => [\&seeCode, $demo],
    );
    $w_see->pack(qw(-side left -expand 1));

    $plot::prcmd = 'lpr';
    $w_prcmd = $w->Entry(-textvariable => \$plot::prcmd);
    $w_prcmd->pack;
    $w_prcmd->bind('<Return>' => [$w_print, 'invoke']);

    my $plot_font = '-*-Helvetica-Medium-R-Normal--*-180-*-*-*-*-*-*';

    $c->create('line', 100, 250, 400, 250, -width => 2);
    $c->create('line', 100, 250, 100, 50, -width => 2);
    $c->create('text', 225, 20, -text => 'A Simple Plot', -font => $plot_font,
	       -fill => 'brown');
    
    my($i, $x, $y, $point, $item);
    for($i = 0; $i <= 10; $i++) {
	$x = 100 + ($i * 30);
	$c->create('line', $x, 250, $x, 245, -width => 2);
	$c->create('text', $x, 254, -text => 10 * $i, -anchor => 'n',
		   -font => $plot_font);
    } # forend
    for ($i = 0; $i <= 5; $i++) {
	$y =  250 - ($i * 40);
	$c->create('line', 100, $y, 105, $y, -width => 2);
	$c->create('text', 96, $y, -text => $i * 50.0, -anchor => 'e',
		   -font => $plot_font);
    } # forend
    
    foreach $point ([12, 56], [20, 94], [33, 98], [32, 120], [61, 180],
		    [75, 160], [98, 223]) {
	$x = 100 + (3 * ${$point}[0]);
        $y = 250 - (4 * ${$point}[1]) / 5;
        $item = $c->create('oval', $x-6, $y-6, $x+6, $y+6, -width => 1,
			   -outline => 'black', -fill => 'SkyBlue2');
        $c->addtag('point', 'withtag', $item);
    }

    $c->bind('point', '<Any-Enter>' => [sub{shift->itemconfigure(@ARG)},
					qw(current -fill red)]);
    $c->bind('point', '<Any-Leave>' => [sub{shift->itemconfigure(@ARG)},
					qw(current -fill SkyBlue2)]);
    $c->bind('point', '<1>' => sub{plot_down(@ARG)});
    $c->bind('point', '<ButtonRelease-1>' => sub {shift->dtag('selected')});
    $c->Tk::bind('<B1-Motion>' => sub {plot_move(@ARG)});
    $c->Tk::bind('<2>' => sub {area_down(@ARG)});
    $c->Tk::bind('<B2-Motion>' => sub {area_move(@ARG)});
  
} # end plot

sub plot_down {

    my($w) = @ARG;

    my $e = $w->XEvent;
    my($x, $y) = ($e->x, $e->y);
    $w->dtag('selected');
    $w->addtag('selected', 'withtag', 'current');
    $w->raise('current');
    $plot::plot{'lastX'} = $x;
    $plot::plot{'lastY'} = $y;

} # end plot_down

sub plot_move {

    my($w) = @ARG;

    my $e = $w->XEvent;
    my($x, $y) = ($e->x, $e->y);
    $w->move('selected',  $x-$plot::plot{'lastX'},
	     $y-$plot::plot{'lastY'});
    $plot::plot{'lastX'} = $x;
    $plot::plot{'lastY'} = $y;

} # end plot_move

sub area_down {

    my($w) = @ARG;

    my $e = $w->XEvent;
    my($x, $y) = ($e->x, $e->y);
    $plot::plot{'areaX1'} = $x;
    $plot::plot{'areaY1'} = $y;
    $plot::plot{'areaX2'} = -1;
    $plot::plot{'areaY2'} = -1;
    eval {$w->delete('area');};

} # end area_down

sub area_move {

    my($w) = @ARG;

    my $e = $w->XEvent;
    my($x, $y) = ($e->x, $e->y);
    if($x != $plot::plot{'areaX1'} && $y != $plot::plot{'areaY1'}) {
      eval {$w->delete('area');};
      $w->addtag('area','withtag',$w->create('rect',$plot::plot{'areaX1'},
                                           $plot::plot{'areaY1'},$x,$y));
      $plot::plot{'areaX2'} = $x;
      $plot::plot{'areaY2'} = $y;
    }
} # end area_move

sub area_save {
    
    my($w) = @ARG;
    
    my($x1, $x2, $y1, $y2, $a);
    
    if($plot::plot{'areaX2'} != -1) {
	($x1, $x2, $y1, $y2) = 
	  @plot::plot{'areaX1', 'areaX2', 'areaY1', 'areaY2'};
	($x1, $x2) = @plot::plot{'areaX2', 'areaX1'} if $x2 <= $x1;
	($y1, $y2) = @plot::plot{'areaY2', 'areaY1'} if $y2 <= $y1;
	$a = $w->postscript("-x" => $x1, "-y" => $y1,
			    -width => $x2 - $x1, -height => $y2 - $y1);
    } else {
	$a = $w->postscript;
    }
    open(LPR, "| $plot::prcmd");
    print LPR $a;
    close(LPR);

} # end area_save

1;
