# ruler.pl

sub ruler_make_tab;
sub ruler_move_tab;
sub ruler_new_tab;
sub ruler_release_tab;
sub ruler_select_tab;

sub ruler {

    # Create a canvas demonstration consisting of a ruler displays a ruler
    # with tab stops that can be set individually.

    my($demo) = @ARG;

    $RULER->destroy if Exists($RULER);
    $RULER = $MW->Toplevel;
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

    my $c = $w->Canvas(-width => '14.8c', -height => '2.5c');
    $c->pack(-side => 'top', -fill => 'x');

    my %rinfo;			# ruler information hash
    $rinfo{'grid'} = '.25c';
    $rinfo{'left'} = $c->fpixels('1c');
    $rinfo{'right'} = $c->fpixels('13c');
    $rinfo{'top'} = $c->fpixels('1c');
    $rinfo{'bottom'} = $c->fpixels('1.5c');
    $rinfo{'size'} = $c->fpixels('.2c');
    $rinfo{'normalStyle'} = [-fill => 'black'];
    if ($w->depth > 1) {
	$rinfo{'activeStyle'} = [-fill => 'red', -stipple => undef];
	$rinfo{'deleteStyle'} = [
            -fill    => 'red',  
	    -stipple => '@'.Tk->findINC('demos/images/grey.25'),
        ];
    } else {
	$rinfo{'activeStyle'} = [-fill => 'black', -stipple => undef];
	$rinfo{'deleteStyle'} = [
            -fill    => 'black',
            -stipple => '@'.Tk->findINC('demos/images/grey.25'),
        ];
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
    $c->addtag('well', 'withtag', ruler_make_tab($c, $c->pixels('13.5c'),
        $c->pixels('.65c'), \%rinfo));

    $c->bind('well', '<1>' => [sub{ruler_new_tab(@ARG)}, \%rinfo]);
    $c->bind('tab', '<1>' => [sub {ruler_select_tab(@ARG)}, \%rinfo]);
    $c->Tk::bind('<B1-Motion>' => [sub {ruler_move_tab(@ARG)}, \%rinfo]);
    $c->Tk::bind('<Any-ButtonRelease-1>', [sub {ruler_release_tab(@ARG)}, \%rinfo]);

} # end ruler

sub ruler_make_tab {

    my($c, $x, $y, $rinfo) = @ARG;

    return $c->create('polygon', $x, $y, $x+$rinfo->{'size'},
		      $y+$rinfo->{'size'}, $x-$rinfo->{'size'},
		      $y+$rinfo->{'size'});

} # end ruler_make_tab

sub ruler_move_tab {

    my($c, $rinfo) = @ARG;

    return if not defined $c->find('withtag', 'active');
    my $e = $c->XEvent;
    my($x, $y) = ($e->x, $e->y);
    my $cx = $c->canvasx($x, $rinfo->{'grid'});
    my $cy = $c->canvasy($y);
    if ($cx < $rinfo->{'left'}) {
	$cx =  $rinfo->{'left'};
    }
    if ($cx > $rinfo->{'right'}) {
	$cx =  $rinfo->{'right'};
    }
    if (($cy >= $rinfo->{'top'}) and ($cy <= $rinfo->{'bottom'})) {
	$cy =  $rinfo->{'top'} + 2;
	$c->itemconfigure('active', @{$rinfo->{'activeStyle'}});
    } else {
	$cy =  $cy - $rinfo->{'size'} - 2;
	$c->itemconfigure('active', @{$rinfo->{'deleteStyle'}});
    }
    $c->move('active',  $cx-$rinfo->{'x'}, $cy-$rinfo->{'y'});
    $rinfo->{'x'} = $cx;
    $rinfo->{'y'} = $cy;

} # end ruler_move_tab

sub ruler_new_tab {
    
    my($c, $rinfo) = @ARG;

    my $e = $c->XEvent;
    my($x, $y) = ($e->x, $e->y);
    $c->addtag('active', 'withtag', ruler_make_tab($c, $x, $y, $rinfo));
    $c->addtag('tab', 'withtag', 'active');
    $rinfo->{'x'} = $x;
    $rinfo->{'y'} = $y;
    ruler_move_tab($c, $rinfo);

} # end ruler_new_tab

sub ruler_release_tab {

    my($c, $rinfo) = @ARG;

    return if not defined $c->find('withtag', 'active');
    if ($rinfo->{'y'} != $rinfo->{'top'} + 2) {
	$c->delete('active');
    } else {
	$c->itemconfigure('active', @{$rinfo->{'normalStyle'}});
	$c->dtag('active');
    }

} # end ruler_release_tab

sub ruler_select_tab {

    my($c, $rinfo) = @ARG;

    my $e = $c->XEvent;
    my($x, $y) = ($e->x, $e->y);
    $rinfo->{'x'} = $c->canvasx($x, $rinfo->{'grid'});
    $rinfo->{'y'} = $rinfo->{'top'} + 2;
    $c->addtag('active', 'withtag', 'current');
    $c->itemconfigure('active', @{$rinfo->{'activeStyle'}});
    $c->raise('active');

} # end ruler_select_tab

1;
