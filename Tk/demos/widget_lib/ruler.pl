# ruler.pl

sub rulerMkTab;
sub rulerMoveTab;
sub rulerNewTab;
sub rulerReleaseTab;
sub rulerSelectTab;

sub ruler {

    # Create a canvas demonstration consisting of a ruler displays a ruler
    # with tab stops that can be set individually.

    my($demo) = @ARG;

    $RULER->destroy if Exists($RULER);
    $RULER = $mw->Toplevel;
    my $w = $RULER;
    dpos $w;
    $w->title('Ruler Demonstration');
    $w->iconname('ruler');

    my $w_msg = $w->Label(
        -font       => $FONT, 
        -wraplength => '5i',
        -justify    => 'left',
        -text       => 'This canvas widget shows a mock-up of a ruler.  You can create tab stops by dragging them out of the well to the right of the ruler.  You can also drag existing tab stops.  If you drag a tab stop far enough up or down so that it turns dim, it will be deleted when you release the mouse button.',
    );
    $w_msg->pack(-side => 'top');

    my $w_buttons = $w->Frame;
    $w_buttons->pack(qw( -side bottom -expand y -fill x -pady 2m));
    my $w_dismiss = $w_buttons->Button(
        -text    => 'Dismiss',
        -command => ['destroy', $w],
    );
    $w_dismiss->pack(qw(-side left -expand 1));
    my $w_see = $w_buttons->Button(
        -text    => 'See Code',
        -command => [\&seeCode, $demo],
    );
    $w_see->pack(qw(-side left -expand 1));

    my $c = $w->Canvas(-width => '14.8c', -height => '2.5c');
    $c->pack(-side => 'top', -fill => 'x');

    $ruler::info{'grid'} = '.25c';
    $ruler::info{'left'} = $c->fpixels('1c');
    $ruler::info{'right'} = $c->fpixels('13c');
    $ruler::info{'top'} = $c->fpixels('1c');
    $ruler::info{'bottom'} = $c->fpixels('1.5c');
    $ruler::info{'size'} = $c->fpixels('.2c');
    $ruler::info{'normalStyle'} = [-fill => 'black'];
    if ($w->depth > 1) {
	$ruler::info{'activeStyle'} = [-fill => 'red',  
	    -stipple => undef];
	$ruler::info{'deleteStyle'} = [-fill => 'red',  
	    -stipple => "\@$tk_library/demos/images/grey.25"];
    } else {
	$ruler::info{'activeStyle'} = [-fill => 'black',
            -stipple => undef];
	$ruler::info{'deleteStyle'} = [-fill => 'black',
            -stipple => "\@$tk_library/demos/images/grey.25"];
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
    $c->addtag('well', 'withtag', $c->create(qw(rect 13.2c 1c 13.8c 0.5c
        -outline black -fill), ($c->configure(-bg))[4]));
    $c->addtag('well', 'withtag', rulerMkTab($c, $c->pixels('13.5c'),
        $c->pixels('.65c')));

    $c->bind('well', '<1>' => sub{rulerNewTab(@ARG)});
    $c->bind('tab', '<1>' => sub {rulerSelectTab(@ARG)});
    $c->Tk::bind('<B1-Motion>' => sub {rulerMoveTab(@ARG)});
    $c->Tk::bind('<Any-ButtonRelease-1>', sub {rulerReleaseTab(@ARG)});

} # end ruler

sub rulerMkTab {

    my($c, $x, $y) = @ARG;

    return $c->create('polygon', $x, $y, $x+$ruler::info{'size'},
		      $y+$ruler::info{'size'}, $x-$ruler::info{'size'},
		      $y+$ruler::info{'size'});

} # end rulerMkTab

sub rulerMoveTab {

    my($c) = @ARG;

    return if not defined $c->find('withtag', 'active');
    my $e = $c->XEvent;
    my($x, $y) = ($e->x, $e->y);
    my $cx = $c->canvasx($x, $ruler::info{'grid'});
    my $cy = $c->canvasy($y);
    if ($cx < $ruler::info{'left'}) {
	$cx =  $ruler::info{'left'};
    }
    if ($cx > $ruler::info{'right'}) {
	$cx =  $ruler::info{'right'};
    }
    if (($cy >= $ruler::info{'top'}) and ($cy <= $ruler::info{'bottom'})) {
	$cy =  $ruler::info{'top'} + 2;
	$c->itemconfigure('active', @{$ruler::info{'activeStyle'}});
    } else {
	$cy =  $cy - $ruler::info{'size'} - 2;
	$c->itemconfigure('active', @{$ruler::info{'deleteStyle'}});
    }
    $c->move('active',  $cx-$ruler::info{'x'}, $cy-$ruler::info{'y'});
    $ruler::info{'x'} = $cx;
    $ruler::info{'y'} = $cy;

} # end rulerMoveTab

sub rulerNewTab {
    
    my($c) = @ARG;

    my $e = $c->XEvent;
    my($x, $y) = ($e->x, $e->y);
    $c->addtag('active', 'withtag', rulerMkTab($c, $x, $y));
    $c->addtag('tab', 'withtag', 'active');
    $ruler::info{'x'} = $x;
    $ruler::info{'y'} = $y;
    rulerMoveTab($c, $e);

} # end rulerNewTab

sub rulerReleaseTab {

    my($c) = @ARG;

    return if not defined $c->find('withtag', 'active');
    if ($ruler::info{'y'} != $ruler::info{'top'} + 2) {
	$c->delete('active');
    } else {
	$c->itemconfigure('active', @{$ruler::info{'normalStyle'}});
	$c->dtag('active');
    }

} # end rulerReleaseTab

sub rulerSelectTab {

    my($c) = @ARG;

    my $e = $c->XEvent;
    my($x, $y) = ($e->x, $e->y);
    $ruler::info{'x'} = $c->canvasx($x, $ruler::info{'grid'});
    $ruler::info{'y'} = $ruler::info{'top'} + 2;
    $c->addtag('active', 'withtag', 'current');
    $c->itemconfigure('active', @{$ruler::info{'activeStyle'}});
    $c->raise('active');

} # end rulerSelectTab

1;
