
# use subs qw(plot_down plot_move);


$mkPlot::plot{'lastX'} = 0;
$mkPlot::plot{'lastY'} = 0;


sub plot_down {

    my($w) = @_;

    my $e = $w->XEvent;
    my($x, $y) = ($e->x, $e->y);
    $w->dtag('selected');
    $w->addtag('selected', 'withtag', 'current');
    $w->raise('current');
    $mkPlot::plot{'lastX'} = $x;
    $mkPlot::plot{'lastY'} = $y;

} # end plot_down


sub plot_move {

    my($w) = @_;

    my $e = $w->XEvent;
    my($x, $y) = ($e->x, $e->y);
    $w->move('selected',  $x-$mkPlot::plot{'lastX'}, $y-$mkPlot::plot{'lastY'});
    $mkPlot::plot{'lastX'} = $x;
    $mkPlot::plot{'lastY'} = $y;

} # end plot_move

sub mkPlot {

    # Create a top-level window containing a canvas displaying a simple graph with data points that can be moved interactively.

    $mkPlot->destroy if Exists($mkPlot);
    $mkPlot = $top->Toplevel();
    my $w = $mkPlot;
    dpos $w;
    $w->title('Plot Demonstration');
    $w->iconname('Plot');

    my $w_msg = $w->Label(-font => '-Adobe-Times-Medium-R-Normal--*-180-*-*-*-*-*-*', -wraplength => '4i',
			     -justify => 'left', -text => 'This window displays a canvas widget containing a simple ' .
			     '2-dimensional plot.  You can doctor the data by dragging any of the points with mouse ' .
			     'button 1.');
    my $c = $w->Canvas(-relief => 'raised', -width => '450', -height => '300');
    my $w_ok = $w->Button(-text => 'OK', -width => 8, -command => ['destroy', $w]);
    $w_msg->pack(-side => 'top', -fill => 'x');
    $c->pack(-side => 'top', -fill => 'x');
    $w_ok->pack(-side => 'bottom', -pady => '5');

    my $font = '-Adobe-helvetica-medium-r-Normal--*-180-*-*-*-*-*-*';

    $c->create('line', 100, 250, 400, 250, -width => 2);
    $c->create('line', 100, 250, 100, 50, -width => 2);
    $c->create('text', 225, 20, -text => 'A Simple Plot', -font => $font, -fill => 'brown');

    my($i, $x, $y, $point, $item);
    for($i = 0; $i <= 10; $i++) {
	$x = 100 + ($i * 30);
	$c->create('line', $x, 250, $x, 245, -width => 2);
	$c->create('text', $x, 254, -text => 10 * $i, -anchor => 'n', -font => $font);
    } # forend
    for ($i = 0; $i <= 5; $i++) {
	$y =  250 - ($i * 40);
	$c->create('line', 100, $y, 105, $y, -width => 2);
	$c->create('text', 96, $y, -text => $i * 50.0, -anchor => 'e',  -font => $font);
    } # forend

    foreach $point ([12, 56], [20, 94], [33, 98], [32, 120], [61, 180], [75, 160], [98, 223]) {
	$x = 100 + (3 * ${$point}[0]);
        $y = 250 - (4 * ${$point}[1]) / 5;
        $item = $c->create('oval', $x-6, $y-6, $x+6, $y+6, -width => 1, -outline => 'black', -fill => 'SkyBlue2');
        $c->addtag('point', 'withtag', $item);
    }

    $c->bind('point', '<Any-Enter>' => [sub{shift->itemconfigure(@_)}, qw(current -fill red)]);
    $c->bind('point', '<Any-Leave>' => [sub{shift->itemconfigure(@_)}, qw(current -fill SkyBlue2)]);
    $c->bind('point', '<1>' => sub{plot_down(@_)});
    $c->bind('point', '<ButtonRelease-1>' => sub {shift->dtag('selected')});
    $c->Tk::bind('<B1-Motion>' => sub {plot_move(@_)});

} # end mkPlot


1;
