

sub rulerMkTab {

    my($c, $x, $y) = @_;

    return $c->create('polygon', $x, $y, $x+$ruler_info{'size'}, $y+$ruler_info{'size'}, $x-$ruler_info{'size'},
		      $y+$ruler_info{'size'});

} # end rulerMkTab


sub rulerMoveTab {

    my($c) = @_;

    return if not defined $c->find('withtag', 'active');
    my $e = $c->XEvent;
    my($x, $y) = ($e->x, $e->y);
    my $cx = $c->canvasx($x, $ruler_info{'grid'});
    my $cy = $c->canvasy($y);
    if ($cx < $ruler_info{'left'}) {
	$cx =  $ruler_info{'left'};
    }
    if ($cx > $ruler_info{'right'}) {
	$cx =  $ruler_info{'right'};
    }
    if (($cy >= $ruler_info{'top'}) and ($cy <= $ruler_info{'bottom'})) {
	$cy =  $ruler_info{'top'} + 2;
	$c->itemconfigure('active', @{$ruler_info{'activeStyle'}});
    } else {
	$cy =  $cy - $ruler_info{'size'} - 2;
	$c->itemconfigure('active', @{$ruler_info{'deleteStyle'}});
    }
    $c->move('active',  $cx-$ruler_info{'x'}, $cy-$ruler_info{'y'});
    $ruler_info{'x'} = $cx;
    $ruler_info{'y'} = $cy;

} # end rulerMoveTab


sub rulerNewTab {

    my($c) = @_;

    my $e = $c->XEvent;
    my($x, $y) = ($e->x, $e->y);
    $c->addtag('active', 'withtag', rulerMkTab($c, $x, $y));
    $c->addtag('tab', 'withtag', 'active');
    $ruler_info{'x'} = $x;
    $ruler_info{'y'} = $y;
    rulerMoveTab($c, $e);

} # end rulerNewTab


sub rulerReleaseTab {

    my($c) = @_;

    return if not defined $c->find('withtag', 'active');
    if ($ruler_info{'y'} != $ruler_info{'top'} + 2) {
	$c->delete('active');
    } else {
	$c->itemconfigure('active', @{$ruler_info{'normalStyle'}});
	$c->dtag('active');
    }

} # end rulerReleaseTab


sub rulerSelectTab {

    my($c) = @_;

    my $e = $c->XEvent;
    my($x, $y) = ($e->x, $e->y);
    $ruler_info{'x'} = $c->canvasx($x, $ruler_info{'grid'});
    $ruler_info{'y'} = $ruler_info{'top'} + 2;
    $c->addtag('active', 'withtag', 'current');
    $c->itemconfigure('active', @{$ruler_info{'activeStyle'}});
    $c->raise('active');

} # end rulerSelectTab

sub mkRuler {

    # Create a canvas demonstration consisting of a ruler displays a ruler with tab stops that can be set individually.

    $mkRuler->destroy if Exists($mkRuler);
    $mkRuler = $top->Toplevel();
    my $w = $mkRuler;
    dpos $w;
    $w->title('Ruler Demonstration');
    $w->iconname('Ruler');

    my $w_msg = $w->Label(-font => '-Adobe-Times-Medium-R-Normal--*-180-*-*-*-*-*-*', -wraplength => '13c',
			     -justify => 'left', -text => 'This canvas widget shows a mock-up of a ruler.  You can create tab ' .
			     'stops by dragging them out of the well to the right of the ruler.  You can also drag ' .
			     'existing tab stops.  If you drag a tab stop far enough up or down so that it turns dim, it ' .
			     'will be deleted when you release the mouse button.');
    my $c = $w->Canvas(-width => '14.8c', -height => '2.5c');
    my $w_ok = $w->Button(-text => 'OK', -width => 8, -command => ['destroy', $w]);
    $w_msg->pack(-side => 'top', -fill => 'x');
    $c->pack(-side => 'top', -fill => 'x');
    $w_ok->pack(-side => 'bottom', -pady => '5');

    $ruler_info{'grid'} = '.25c';
    $ruler_info{'left'} = $c->fpixels('1c');
    $ruler_info{'right'} = $c->fpixels('13c');
    $ruler_info{'top'} = $c->fpixels('1c');
    $ruler_info{'bottom'} = $c->fpixels('1.5c');
    $ruler_info{'size'} = $c->fpixels('.2c');
    $ruler_info{'normalStyle'} = [-fill => 'black'];
    if ($mkRuler->depth > 1) {
	$ruler_info{'activeStyle'} = [-fill => 'red',   -stipple => undef];
	$ruler_info{'deleteStyle'} = [-fill => 'red',   -stipple => '@'.Tk->findINC('demos/images/grey.25')];
    } else {
	$ruler_info{'activeStyle'} = [-fill => 'black', -stipple => undef];
	$ruler_info{'deleteStyle'} = [-fill => 'black', -stipple => '@'.Tk->findINC('demos/images/grey.25')];
    }

    $c->create(qw(line 1c 0.5c 1c 1c 13c 1c 13c 0.5c -width 1));
    for ($i = 0; $i < 12; $i++) {
	my $x = $i+1;
	$c->create('line', "$x.c",  '1c', "$x.c",  '0.6c', -width => 1);
	$c->create('line', "$x.25c", '1c', "$x.25c", '0.8c', -width => 1);
	$c->create('line', "$x.5c",  '1c', "$x.5c",  '0.7c', -width => 1);
	$c->create('line', "$x.75c", '1c', "$x.75c", '0.8c', -width => 1);
	$c->create('text', "$x.15c", '.75c',-text => $i, -anchor => 'sw');
    }
    $c->addtag('well', 'withtag', $c->create(qw(rect 13.2c 1c 13.8c 0.5c -outline black -fill), ($c->configure(-bg))[4]));
    $c->addtag('well', 'withtag', rulerMkTab($c, $c->pixels('13.5c'), $c->pixels('.65c')));

    $c->bind('well', '<1>' => sub{rulerNewTab(@_)});
    $c->bind('tab', '<1>' => sub {rulerSelectTab(@_)});
    $c->Tk::bind('<B1-Motion>' => sub {rulerMoveTab(@_)});
    $c->Tk::bind('<Any-ButtonRelease-1>', sub {rulerReleaseTab(@_)});

} # end mkRuler

1;
