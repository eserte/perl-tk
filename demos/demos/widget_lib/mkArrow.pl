

sub arrowSetup {

    # The procedure below completely regenerates all the text and graphics in the canvas window.  It's called when the canvas
    # is initially created, and also whenever any of the parameters of the arrow head are changed interactively.  The argument
    # is the name of the canvas widget to be regenerated, and also the name of a global variable containing the parameters
    # for the display.

    my($c) = @_;

    # Remember the current box, if there is one.

    my(@tags) = $c->gettags('current');
    my $cur = defined $tags[0] ? $tags[lsearch('box?', @tags)] : '';

    # Create the arrow and outline.

    *v = *demoArrowInfo;
    $c->delete('all');
    $c->create('line', $v{'x1'}, $v{'y'}, $v{'x2'}, $v{'y'}, -width => 10*$v{'width'},
	       -arrowshape => [10*$v{'a'}, 10*$v{'b'}, 10*$v{'c'}], -arrow => 'last', @{$v{'bigLineStyle'}});
    my $xtip = $v{'x2'}-10*$v{'b'};
    my $deltaY =  10*$v{'c'}+5*$v{'width'};
    $c->create('line', $v{'x2'}, $v{'y'}, $xtip, $v{'y'}+$deltaY, $v{'x2'}-10*$v{'a'}, $v{'y'}, $xtip, $v{'y'}-$deltaY,
	       $v{'x2'}, $v{'y'}, -width => 2, -capstyle => 'round', -joinstyle => 'round');

    # Create the boxes for reshaping the line and arrowhead.

    $c->create('rectangle', $v{'x2'}-10*$v{'a'}-5, $v{'y'}-5, $v{'x2'}-10*$v{'a'}+5, $v{'y'}+5, @{$v{'boxStyle'}},
	       -tags => ['box1', 'box']);
    $c->create('rectangle', $xtip-5, $v{'y'}-$deltaY-5, $xtip+5, $v{'y'}-$deltaY+5, @{$v{'boxStyle'}},
	       -tags => ['box2', 'box']);
    $c->create('rectangle', $v{'x1'}-5, $v{'y'}-5*$v{'width'}-5, $v{'x1'}+5, $v{'y'}-5*$v{'width'}+5, @{$v{'boxStyle'}},
	       -tags => ['box3', 'box']);

    # Create three arrows in actual size with the same parameters

    $c->create('line', $v{'x2'}+50, 0, $v{'x2'}+50, 1000, -width => 2);
    my $tmp = $v{'x2'}+100;
    $c->create('line', $tmp, $v{'y'}-125, $tmp, $v{'y'}-75, -width => $v{'width'}, -arrow => 'both',
	       -arrowshape => [$v{'a'}, $v{'b'}, $v{'c'}]);
    $c->create('line', $tmp-25, $v{'y'}, $tmp+25, $v{'y'}, -width => $v{'width'}, -arrow => 'both',
	       -arrowshape =>[$v{'a'}, $v{'b'}, $v{'c'}]);
    $c->create('line', $tmp-25, $v{'y'}+75, $tmp+25, $v{'y'}+125, -width => $v{'width'}, -arrow => 'both',
	       -arrowshape => [$v{'a'}, $v{'b'}, $v{'c'}]);
    $c->itemconfigure($cur, @{$v{'activeStyle'}}) if $cur =~ /box?/;

    # Create a bunch of other arrows and text items showing the current dimensions.

    $tmp = $v{'x2'}+10;
    $c->create('line', $tmp, $v{'y'}-5*$v{'width'}, $tmp, $v{'y'}-$deltaY, -arrow => 'both', -arrowshape => $v{'smallTips'});
    $c->create('text', $v{'x2'}+15, $v{'y'}-$deltaY+5*$v{'c'}, -text => $v{'c'}, -anchor => 'w');
    $tmp =  $v{'x1'}-10;
    $c->create('line', $tmp, $v{'y'}-5*$v{'width'}, $tmp, $v{'y'}+5*$v{'width'}, -arrow => 'both',
	       -arrowshape => $v{'smallTips'});
    $c->create('text', $v{'x1'}-15, $v{'y'}, -text => $v{'width'}, -anchor => 'e');
    $tmp = $v{'y'}+5*$v{'width'}+10*$v{'c'}+10;
    $c->create('line', $v{'x2'}-10*$v{'a'}, $tmp, $v{'x2'}, $tmp, -arrow => 'both', -arrowshape => $v{'smallTips'});
    $c->create('text', $v{'x2'}-5*$v{'a'}, $tmp+5, -text => $v{'a'}, -anchor => 'n');
    $tmp = $tmp+25;
    $c->create('line', $v{'x2'}-10*$v{'b'}, $tmp, $v{'x2'}, $tmp, -arrow => 'both', -arrowshape => $v{'smallTips'});
    $c->create('text', $v{'x2'}-5*$v{'b'}, $tmp+5, -text => $v{'b'}, -anchor => 'n');

    $c->create('text', $v{'x1'}, 310, -text => "\"-width\" =>  $v{'width'}", -anchor => 'w',
	       -font => '-Adobe-Helvetica-Medium-R-Normal--*-180-*-*-*-*-*-*');
    $c->create('text', $v{'x1'}, 330, -text => "\"-arrowshape\" =>  [$v{'a'},  $v{'b'},  $v{'c'}]", -anchor => 'w',
	       -font => '-Adobe-Helvetica-Medium-R-Normal--*-180-*-*-*-*-*-*');

    $v{'count'}++;

} # end arrowSetup


# The procedures below are called in response to mouse motion for one of the three items used to change the line width and
# arrowhead shape.  Each procedure updates one or more of the controlling parameters for the line and arrowhead, and recreates
# the display if that is needed.  The arguments are the name of the canvas widget, and the x and y positions of the mouse
# within the widget.


sub arrowMove1 {

    my($c) = @_;
    my $e = $c->XEvent;

    *v = *demoArrowInfo;
    my($x, $y, $err) = ($e->x, $e->y, 0);
    my $newA = int(($v{'x2'} + 5 - int($c->canvasx($x))) / 10);
    $newA = 0, $err = 1 if $newA < 0;
    $newA = 25, $err = 1 if $newA > 25;
    if ($newA != $v{'a'}) {
	$c->move('box1', 10 * ($v{'a'} - $newA), 0);
	$v{'a'} = $newA;
    }
    arrow_err($c) if $err;

} # end arrowMove1


sub arrowMove2 {

    my($c) = @_;
    my $e = $c->XEvent;

    *v = *demoArrowInfo;
    my($x, $y, $errx, $erry) = ($e->x, $e->y, 0, 0);
    my $newB = int(($v{'x2'} + 5 - int($c->canvasx($x))) / 10);
    $newB = 0, $errx = 1 if $newB < 0;
    $newB = 25, $errx = 1 if $newB > 25;
    my $newC = int(($v{'y'} + 5 - int($c->canvasy($y)) - 5 * $v{'width'}) / 10);
    $newC = 0, $erry = 1 if $newC < 0;
    $newC = 12, $erry = 1 if $newC > 12;
    if (($newB != $v{'b'}) or ($newC != $v{'c'})) {
	$c->move('box2', 10*($v{'b'}-$newB), 10*($v{'c'}-$newC));
	$v{'b'} = $newB;
	$v{'c'} = $newC;
    }
    arrow_err($c) if $errx or $erry;

} # end arrowMove2


sub arrowMove3 {

    my($c) = @_;
    my $e = $c->XEvent;

    *v = *demoArrowInfo;
    my($x, $y, $err) = ($e->x, $e->y, 0);
    my $newWidth = int(($v{'y'} + 2 - int($c->canvasy($y))) / 5);
    $newWidth = 0, $err = 1 if $newWidth < 0;
    $newWidth = 20, $err = 1 if $newWidth > 20;
    if ($newWidth != $v{'width'}) {
	$c->move('box3', 0, 5*($v{'width'}-$newWidth));
	$v{'width'} = $newWidth;
    }
    arrow_err($c) if $err;

} # end arrowMove3


sub arrow_err {

    my($c) = @_;

    my $i = $c->create(qw(text .6i .1i -anchor n), -text => "Range error!");
    $c->after(4000, sub { $c->delete($i) });

} # end errow_err

sub mkArrow {

    # Create a top-level window containing a canvas demonstration that allows the user to experiment with arrow shapes.

    $mkArrow->destroy if Exists($mkArrow);
    $mkArrow = $top->Toplevel();
    my $w = $mkArrow;
    dpos $w;
    $w->title('Arrowhead Editor Demonstration');
    $w->iconname('Arrow');

    my $w_msg = $w->Label(-font => '-Adobe-Times-Medium-R-Normal--*-180-*-*-*-*-*-*', -wraplength => '5i',
				-justify => 'left', -text => 'This widget allows you to experiment with different widths ' .
				'and arrowhead shapes for lines in canvases.  To change the line width or the shape of the ' .
				'arrowhead, drag any of the three boxes attached to the oversized arrow.  The arrows on ' .
				'the right give examples at normal scale.  The text at the bottom shows the configuration ' .
				'options as you\'d enter them for a line.');
    my $c = $w->Canvas(-width => '500', -height => '350', -relief => 'sunken', -bd => 2);
    my $w_ok = $w->Button(-text => 'OK', -width => 8, -command => ['destroy', $w]);
    $w_msg->pack(-side => 'top', -fill => 'both');
    $w_ok->pack(-side => 'bottom', -pady => '5');
    $c->pack(-expand => 'yes', -fill => 'both');

    $demoArrowInfo{'a'} = 8;
    $demoArrowInfo{'b'} = 10;
    $demoArrowInfo{'c'} = 3;
    $demoArrowInfo{'width'} = 2;
    $demoArrowInfo{'motionProc'} = 'arrowMoveNull';
    $demoArrowInfo{'x1'} = 40;
    $demoArrowInfo{'x2'} = 350;
    $demoArrowInfo{'y'} = 150;
    $demoArrowInfo{'smallTips'} = [5, 5, 2];
    $demoArrowInfo{'count'} = 0;
    if ($mkArrow->depth > 1) {
	$demoArrowInfo{'bigLineStyle'} = [-fill => 'SkyBlue1'];
	$demoArrowInfo{'boxStyle'}     = [-fill => undef, -outline => 'black', -width => 1];
	$demoArrowInfo{'activeStyle'}  = [-fill => 'red', -outline => 'black', -width => 1];
    } else {
	$demoArrowInfo{'bigLineStyle'} = [-fill => 'black',  -stipple => '@'.Tk->findINC('demos/images/grey.25')];
	$demoArrowInfo{'boxStyle'}     = [-fill => "", -outline => 'black',  -width => 1];
	$demoArrowInfo{'activeStyle'}  = [-fill => 'black', -outline => 'black', -width => 1];
    }
    arrowSetup $c;
    $c->bind('box', '<Enter>' => [sub {
	my($c, @args) = @_;
	$c->itemconfigure(@args);
    }, 'current', @{$demoArrowInfo{'activeStyle'}}]);
    $c->bind('box', '<Leave>' => [sub {
	my($c, @args) = @_;
	$c->itemconfigure(@args);
    }, 'current', @{$demoArrowInfo{'boxStyle'}}]);
    $c->bind('box', '<B1-Enter>' => undef);
    $c->bind('box', '<B1-Leave>' => undef);
    $c->bind('box1', '<1>' => sub {
	$demo_arrowInfo{'motionProc'} = \&arrowMove1;
    });
    $c->bind('box2', '<1>' => sub {
	$demo_arrowInfo{'motionProc'} = \&arrowMove2;
    });
    $c->bind('box3', '<1>', sub {
	$demo_arrowInfo{'motionProc'} = \&arrowMove3;
    });
    $c->bind('box', '<B1-Motion>' => sub {
	&{$demo_arrowInfo{'motionProc'}}(@_);
    });
    $c->Tk::bind('<Any-ButtonRelease-1>', sub {arrowSetup(@_)});

} # end mkArrow

1;
