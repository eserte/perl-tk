

sub scroll_enter {

    my($c) = @_;

    my $id = $c->find('withtag', 'current');
    $id-- if ($c->gettags('current'))[0] eq 'text';
    $mkScroll::old_fill = ($c->itemconfigure($id, -fill))[4];
    if ($mkScroll->depth > 1) {
	$c->itemconfigure($id, -fill => 'SeaGreen1');
    } else {
	$c->itemconfigure($id, -fill => 'black');
	$c->itemconfigure($id+1, -fill => 'white');
    }

} # end scroll_enter


sub scroll_leave {

    my($c) = @_;

    my $id = $c->find('withtag', 'current');
    $id-- if ($c->gettags('current'))[0] eq 'text';
    $c->itemconfigure($id, -fill => $mkScroll::old_fill);
    $c->itemconfigure($id+1, -fill => 'black');

} # end scroll_leave


sub scroll_button {

    my($c) = @_;

    my $id = $c->find('withtag', 'current');
    $id++ if ($c->gettags('current'))[0] ne 'text';
    print STDOUT 'You buttoned at ', ($c->itemconfigure($id, -text))[4], "\n";

} # end scroll_button

sub mkScroll {

    # Create a top-level window containing a simple canvas that can be scrolled in two dimensions.

    $mkScroll->destroy if Exists($mkScroll);
    $mkScroll = $top->Toplevel();
    my $w = $mkScroll;
    dpos $w;
    $w->title('Scrollable Canvas Demonstration');
    $w->iconname('Canvas');
    $w->minsize(100, 100);

    my $w_msg = $w->Label(-font => '-Adobe-Times-Medium-R-Normal--*-180-*-*-*-*-*-*', -wraplength => '4i',
			   -justify => 'left', -text => 'This window displays a canvas widget that can be scrolled either ' .
			   'using the scrollbars or by dragging with button 2 in the canvas.  If you click button 1 on one ' .
			   'of the rectangles, its indices will be printed on stdout.');
    my $w_frame = $w->Frame();
    my $w_ok = $w->Button(-text => 'OK', -width => 8, -command => ['destroy', $w]);
    $w_msg->pack(-side => 'top', -fill => 'x');
    $w_ok->pack(-side => 'bottom', -pady => '5');
    $w_frame->pack(-side => 'top', -expand => 'yes', -fill => 'both');

    my $c = $w_frame->Canvas(-relief => 'sunken', -bd => 2, -scrollregion => ['-10c', '-10c', '50c', '20c']);
    my $w_frame_vscroll = $w_frame->Scrollbar(-command => ['yview', $c]);
    my $w_frame_hscroll = $w_frame->Scrollbar(-command => ['xview', $c], -orient => 'horiz');
    $c->configure(-xscrollcommand => ['set', $w_frame_hscroll], -yscrollcommand => ['set', $w_frame_vscroll]);
    $w_frame_vscroll->pack(-side => 'right', -fill => 'y');
    $w_frame_hscroll->pack(-side => 'bottom', -fill => 'x');
    $c->pack(-expand => 'yes', -fill => 'both');

    my($bg, $i, $j, $x, $y) = ($c->configure(-background))[4];
    for ($i = 0; $i < 20; $i++) {
	$x = -10 + 3 * $i;
	$j = 0;
	$y = -10;
	while ($j < 10) {
	    $c->create('rectangle', sprintf("%dc", $x), sprintf("%dc", $y), sprintf("%dc", $x+2), sprintf("%dc", $y+2),
		       -outline => 'black', -fill => $bg, -tags => 'rect');
	    $c->create('text', sprintf("%dc", $x+1), sprintf("%dc", $y+1), -text => "$i,$j", -anchor => 'center',
		       -tags => 'text');
	    $j++;
	    $y += 3;
	} # whilend
    } # forend

    $c->bind('all', '<Any-Enter>' => sub {scroll_enter(@_)});
    $c->bind('all', '<Any-Leave>' => sub {scroll_leave(@_)});
    $c->bind('all', '<1>' => sub {scroll_button(@_)});
    $c->Tk::bind('<2>' => sub {
	my ($c) = @_;
        my $e = $c->XEvent;
	$c->scan('mark', $e->x, $e->y);
    });
    $c->Tk::bind('<B2-Motion>' => sub {
	my ($c) = @_;
        my $e = $c->XEvent;
	$c->scan('dragto', $e->x, $e->y);
    });

} # end MkScroll

1;
