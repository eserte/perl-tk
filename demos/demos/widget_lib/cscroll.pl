# cscroll.pl

sub cscroll_button;
sub cscroll_enter;
sub cscroll_leave;

sub cscroll {

    # Create a top-level window containing a simple canvas that can be
    # scrolled in two dimensions.

    my($demo) = @ARG;

    $CSCROLL->destroy if Exists($CSCROLL);
    $CSCROLL = $MW->Toplevel;
    my $w = $CSCROLL;
    dpos $w;
    $w->title('Scrollable Canvas Demonstration');
    $w->iconname('cscroll');

    my $w_msg = $w->Label(
        -font       => $FONT,
        -wraplength => '4i',
        -justify    => 'left',
        -text       => 'This window displays a canvas widget that can be scrolled either using the scrollbars or by dragging with button 2 in the canvas.  If you click button 1 on one of the rectangles, its indices will be printed on stdout.',
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

    my $c = $w->Canvas(
        -relief       => 'sunken',
        -bd           => 2,
        -scrollregion => ['-10c', '-10c', '50c', '20c'],
    );
    my $w_vscroll = $w->Scrollbar(-command => [$c => 'yview']);
    my $w_hscroll = $w->Scrollbar(-command =>
				  [$c => 'xview'], -orient => 'horiz');
    $c->configure(-xscrollcommand => [$w_hscroll => 'set'],
		  -yscrollcommand => [$w_vscroll => 'set']);
    $w_vscroll->pack(-side => 'right', -fill => 'y');
    $w_hscroll->pack(-side => 'bottom', -fill => 'x');
    $c->pack(-expand => 'yes', -fill => 'both');

    my($bg, $i, $j, $x, $y) = ($c->configure(-background))[4];
    for ($i = 0; $i < 20; $i++) {
	$x = -10 + 3 * $i;
	$j = 0;
	$y = -10;
	while ($j < 10) {
	    $c->create('rectangle', sprintf("%dc", $x), sprintf("%dc", $y),
		       sprintf("%dc", $x+2), sprintf("%dc", $y+2),
		       -outline => 'black', -fill => $bg, -tags => 'rect');
	    $c->create('text', sprintf("%dc", $x+1), sprintf("%dc", $y+1),
		       -text => "$i,$j", -anchor => 'center', -tags => 'text');
	    $j++;
	    $y += 3;
	} # whilend
    } # forend

    my $old_fill = '';
    $c->bind('all', '<Any-Enter>' => [sub {cscroll_enter(@ARG)}, \$old_fill]);
    $c->bind('all', '<Any-Leave>' => [sub {cscroll_leave(@ARG)}, \$old_fill]);
    $c->bind('all', '<1>' => sub {cscroll_button(@ARG)});
    $c->Tk::bind('<2>' => sub {
	my ($c) = @ARG;
        my $e = $c->XEvent;
	$c->scan('mark', $e->x, $e->y);
    });
    $c->Tk::bind('<B2-Motion>' => sub {
	my ($c) = @ARG;
        my $e = $c->XEvent;
	$c->scan('dragto', $e->x, $e->y);
    });

} # end cscroll

sub cscroll_button {

    my($c) = @ARG;

    my $id = $c->find('withtag', 'current');
    $id++ if ($c->gettags('current'))[0] ne 'text';
    print STDOUT 'You buttoned at ', ($c->itemconfigure($id, -text))[4], "\n";

} # end cscroll_button

sub cscroll_enter {

    my($c, $old_fill) = @ARG;

    my $id = $c->find('withtag', 'current');
    $id-- if ($c->gettags('current'))[0] eq 'text';
    $$old_fill = ($c->itemconfigure($id, -fill))[4];
    if ($CSCROLL->depth > 1) {
	$c->itemconfigure($id, -fill => 'SeaGreen1');
    } else {
	$c->itemconfigure($id, -fill => 'black');
	$c->itemconfigure($id+1, -fill => 'white');
    }

} # end cscroll_enter

sub cscroll_leave {

    my($c, $old_fill) = @ARG;

    my $id = $c->find('withtag', 'current');
    $id-- if ($c->gettags('current'))[0] eq 'text';
    $c->itemconfigure($id, -fill => $$old_fill);
    $c->itemconfigure($id+1, -fill => 'black');

} # end cscroll_leave

1;
