

# Utility procedures for highlighting the item under the pointer:


sub itemEnter {

    my($c) = @_;

    $mkItems::restoreCmd = '';

    if ($mkItems->depth == 1) {
	$mkItems::restoreCmd = '';
	return;
    }
    my $type = $c->type('current');
    if ($type eq 'window') {
	$mkItems::restoreCmd = '';
	return;
    }

    if ($type eq 'bitmap') {
	my $bg = ($c->itemconfigure('current', -background))[4];
	if (defined $bg) {
	    $mkItems::restoreCmd = "\$c->itemconfigure('current', -background => '$bg');";
	} else {
	    $mkItems::restoreCmd = "\$c->itemconfigure('current', -background => undef);";
	}
	$c->itemconfigure('current', -background => 'SteelBlue2');
	return;
    }
    my $fill = ($c->itemconfigure('current', -fill))[4];
    if (($type eq 'rectangle' or $type eq 'oval' or $type eq 'arc') and not defined $fill) {
	my $outline = ($c->itemconfigure('current', -outline))[4];
	$mkItems::restoreCmd = "\$c->itemconfigure('current', -outline => '$outline')";
	$c->itemconfigure('current', -outline => 'SteelBlue2');
    } else {
	$mkItems::restoreCmd = "\$c->itemconfigure('current', -fill => '$fill')";
	$c->itemconfigure('current', -fill => 'SteelBlue2');
    }

} # end itemEnter


sub itemLeave {

    local ($c) = @_;

    eval $mkItems::restoreCmd;

} # end itemLeave


# Utility procedures to support dragging of items.


sub itemStartDrag {

    my($c, $x, $y) = @_;

    $mkItems::lastX = $c->canvasx($x);
    $mkItems::lastY = $c->canvasy($y);

} # end itemStartDrag


sub itemDrag {

    my($c, $x, $y) = @_;

    $x = $c->canvasx($x);
    $y = $c->canvasy($y);
    $c->move('current', $x-$mkItems::lastX, $y-$mkItems::lastY);
    $mkItems::lastX = $x;
    $mkItems::lastY = $y;

} # end itemDrag


# Utility procedures for stroking out a rectangle and printing what's underneath the rectangle's area.


$mkItems::areaX1 = 0;
$mkItems::areaY1 = 0;
$mkItems::areaX2 = 0;
$mkItems::areaY2 = 0;


sub itemMark {

    my($c, $x, $y) = @_;

    $mkItems::areaX1 = $c->canvasx($x);
    $mkItems::areaY1 = $c->canvasy($y);
    $c->delete('area');

} # end itemMark


sub itemStroke {

    my($c, $x, $y) = @_;

    $x = $c->canvasx($x);
    $y = $c->canvasy($y);
    if (($mkItems::areaX1 != $x) and ($mkItems::areaY1 != $y)) {
	$c->delete('area');
	$c->addtag('area', 'withtag', $c->create('rectangle', $mkItems::areaX1, $mkItems::areaY1, $x, $y, -outline => 'black'));
	$mkItems::areaX2 = $x;
	$mkItems::areaY2 = $y;
    }

} # end itemStroke


sub itemsUnderArea {

    my($c) = @_;

    my $area = $c->find('withtag', 'area');
    my @items  = ();
    my $i;
    foreach $i ($c->find('enclosed', $mkItems::areaX1, $mkItems::areaY1, $mkItems::areaX2, $mkItems::areaY2)) {
	my @tags = $c->gettags($i);
	if (defined($tags[0]) and grep $_ eq 'item', @tags) {
	    push @items, $i;
	}
    }
    @items = 'None' unless @items;
    print STDOUT 'Items enclosed by area:  ', join(' ', @items), ".\n";
    @items = ();
    foreach $i ($c->find('overlapping', $mkItems::areaX1, $mkItems::areaY1, $mkItems::areaX2, $mkItems::areaY2)) {
	my @tags = $c->gettags($i);
	if (defined($tags[0]) and grep $_ eq 'item', @tags) {
	    push @items, $i;
	}
    }
    @items = 'None' unless @items;
    print STDOUT 'Items overlapping area:  ', join(' ', @items), ".\n";

} # end itemsUnderArea


sub butPress {

    # Procedure that's invoked when the button embedded in the canvas is invoked.

    my($w, $color) = @_;

    my $i = $w->create(qw(text 25c 18.1c -anchor n), -text => 'Ouch!!', -fill => $color);
    $w->after(500, sub { $w->delete($i) });

} # end butPress


sub mkItems {

    # Create a top-level window containing a canvas that displays the various item types and allows them to be selected and
    # moved.  This demo can be used to test out the point-hit and rectangle-hit code for items.

    $mkItems->destroy if Exists($mkItems);
    $mkItems = $top->Toplevel();
    my $w = $mkItems;
    dpos $w;
    $w->title('Canvas Item Demonstration');
    $w->iconname('Items');
    $w->minsize(100, 100);


    my $w_msg = $w->Label(-font => '-Adobe-Times-Medium-R-Normal--*-180-*-*-*-*-*-*', -wraplength => '5i',
			   -justify => 'left', -text => "This window contains a canvas widget with examples of the various " .
			   "kinds of items supported by canvases.  The following operations are supported:\n  Button-1 " .
			   "drag:\tmoves item under pointer.\n  Button-2 drag:\trepositions view.\n  Button-3 drag:\t" .
			   "strokes out area.\n Ctrl+f:\t\tdisplays items under area.");
    my $w_frame2 = $w->Frame();
    my $w_ok = $w->Button(-text => 'OK', -width => 8, -command => ['destroy', $w]);
    $w_msg->pack(-side => 'top', -fill => 'x');
    $w_frame2->pack(-side => 'top', -fill => 'both', -expand => 'yes');
    $w_ok->pack(-side => 'bottom', -pady => '5', -anchor => 'center');

    my $c = $w_frame2->Canvas(-scrollregion => ['0c', '0c', '30c', '24c'], -width => '15c', -height => '10c',
			-relief => 'sunken', -bd => 2);
    my $w_frame2_vscroll = $w_frame2->Scrollbar(-command => ['yview', $c]);
    my $w_frame2_hscroll = $w_frame2->Scrollbar(-orient => 'horiz', -command => ['xview', $c]);
    $c->configure(-xscrollcommand => ['set', $w_frame2_hscroll]);
    $c->configure(-yscrollcommand => ['set', $w_frame2_vscroll]);
    $w_frame2_hscroll->pack(-side => 'bottom', -fill => 'x');
    $w_frame2_vscroll->pack(-side => 'right', -fill => 'y');
    $c->pack(-expand => 'yes', -fill => 'both');

    # Display a 3x3 rectangular grid.

    $c->create(qw(rect 0c 0c 30c 24c -width 2));
    $c->create(qw(line 0c 8c 30c 8c -width 2));
    $c->create(qw(line 0c 16c 30c 16c -width 2));
    $c->create(qw(line 10c 0c 10c 24c -width 2));
    $c->create(qw(line 20c 0c 20c 24c -width 2));

    $font1 = '-Adobe-Helvetica-Medium-R-Normal--*-120-*-*-*-*-*-*';
    $font2 = '-Adobe-Helvetica-Bold-R-Normal--*-240-*-*-*-*-*-*';
    if ($mkItems->depth > 1) {
	$blue = 'DeepSkyBlue3';
	$red = 'red';
	$bisque = 'bisque3';
	$green = 'SeaGreen3';
    } else {
	$blue = 'black';
	$red = 'black';
	$bisque = 'black';
	$green = 'black';
    }

    # Set up demos within each of the areas of the grid.

    $c->create(qw(text 5c .2c -text Lines -anchor n));
    $c->create(qw(line 1c 1c 3c 1c 1c 4c 3c 4c -width 2m), -fill => $blue, qw(-cap butt -join miter -tags item));
    $c->create(qw(line 4.67c 1c 4.67c 4c -arrow last -tags item));
    $c->create(qw(line 6.33c 1c 6.33c 4c -arrow both -tags item));
    $c->create(qw(line 5c 6c 9c 6c 9c 1c 8c 1c 8c 4.8c 8.8c 4.8c 8.8c 1.2c 8.2c 1.2c 8.2c 4.6c 8.6c 4.6c 8.6c 1.4c 8.4c 1.4c
		  8.4c 4.4c -width 3), -fill => $red, qw(-tags item));
    $c->create(qw(line 1c 5c 7c 5c 7c 7c 9c 7c -width .5c), -stipple => '@'.Tk->findINC('demos/images/grey.25'),
	       qw(-arrow both), -arrowshape => [15, 15, 7], qw(-tags item));
    $c->create(qw(line 1c 7c 1.75c 5.8c 2.5c 7c 3.25c 5.8c 4c 7c -width .5c -cap round -join round -tags item));

    $c->create(qw(text 15c .2c), -text => 'Curves (smoothed lines)', qw(-anchor n));
    $c->create(qw(line 11c 4c 11.5c 1c 13.5c 1c 14c 4c -smooth on), -fill =>$blue, qw(-tags item));
    $c->create(qw(line 15.5c 1c 19.5c 1.5c 15.5c 4.5c 19.5c 4c -smooth on -arrow both -width 3 -tags item));
    $c->create(qw(line 12c 6c 13.5c 4.5c 16.5c 7.5c 18c 6c 16.5c 4.5c 13.5c 7.5c 12c 6c -smooth on -width 3m -cap round),
	       -stipple => '@'.Tk->findINC('demos/images/grey.25'), -fill => $red, qw(-tags item));

    $c->create(qw(text 25c .2c -text Polygons -anchor n));
    $c->create(qw(polygon 21c 1.0c 22.5c 1.75c 24c 1.0c 23.25c 2.5c 24c 4.0c 22.5c 3.25c 21c 4.0c 21.75c 2.5c),
	       -fill => $green, qw( -tags item));
    $c->create(qw(polygon 25c 4c 25c 4c 25c 1c 26c 1c 27c 4c 28c 1c 29c 1c 29c 4c 29c 4c), -fill => $red,
	       qw(-smooth on -tags item));
    $c->create(qw(polygon 22c 4.5c 25c 4.5c 25c 6.75c 28c 6.75c 28c 5.25c 24c 5.25c 24c 6.0c 26c 6c 26c 7.5c 22c 7.5c),
	       -stipple => '@'.Tk->findINC('demos/images/grey.25'), qw( -tags item));

    $c->create(qw(text 5c 8.2c -text Rectangles -anchor n));
    $c->create(qw(rectangle 1c 9.5c 4c 12.5c), -outline => $red, qw(-width 3m -tags item));
    $c->create(qw(rectangle 0.5c 13.5c 4.5c 15.5c), -fill => $green, qw(-tags item));
    $c->create(qw(rectangle 6c 10c 9c 15c), -outline => undef, -stipple => '@'.Tk->findINC('demos/images/grey.25'), -fill => $blue,
	       qw(-tags item));

    $c->create(qw(text 15c 8.2c -text Ovals -anchor n));
    $c->create(qw(oval 11c 9.5c 14c 12.5c), -outline => $red, qw(-width 3m -tags item));
    $c->create(qw(oval 10.5c 13.5c 14.5c 15.5c), -fill => $green, qw(-tags item));
    $c->create(qw(oval 16c 10c 19c 15c), -outline => undef, -stipple => '@'.Tk->findINC('demos/images/grey.25'), -fill => $blue,
	       qw(-tags item));

    $c->create(qw(text 25c 8.2c -text Text -anchor n));
    $c->create(qw(rectangle 22.4c 8.9c 22.6c 9.1c));
    $c->create(qw(text 22.5c 9c -anchor n -width 4c), -font => $font1, -text => 'A short string of text, word-wrapped, ' .
	       'justified left, and anchored north (at the top).  The rectangles show the anchor points for each piece ' .
	       'of text.', qw(-tags item));
    $c->create(qw(rectangle 25.4c 10.9c 25.6c 11.1c));
    $c->create(qw(text 25.5c 11c -anchor w), -font => $font1, -fill => $blue, -text => "Several lines,\n each centered\n" .
	       "individually,\nand all anchored\nat the left edge.", qw(-justify center -tags item));
    $c->create(qw(rectangle 24.9c 13.9c 25.1c 14.1c));
    $c->create(qw(text 25c 14c -anchor c), -font => $font2, -fill => $red, -stipple => '@'.Tk->findINC('demos/images/grey.5'),
	       -text => 'Stippled characters', qw(-tags item));

    $c->create(qw(text 5c 16.2c -text Arcs -anchor n));
    $c->create(qw(arc 0.5c 17c 7c 20c), -fill => $green, qw(-outline black -start 45 -extent 270 -style pieslice -tags item));
    $c->create(qw(arc 6.5c 17c 9.5c 20c -width 4m -style arc), -fill => $blue, -stipple => '@'.Tk->findINC('demos/images/grey.25'),
	       qw(-start -135 -extent 270 -tags item));
    $c->create(qw(arc 0.5c 20c 9.5c 24c -width 4m -style pieslice), -fill => undef, -outline => $red,
	       qw(-start 225 -extent -90 -tags item));
    $c->create(qw(arc 5.5c 20.5c 9.5c 23.5c -width 4m -style chord), -fill => $blue, -outline => undef,
	       qw(-start 45 -extent 270  -tags item));

    $c->create(qw(text 15c 16.2c -text Bitmaps -anchor n));
    $c->create(qw(bitmap 13c 20c), -bitmap => '@'.Tk->findINC('demos/images/face'), qw(-tags item));
    $c->create(qw(bitmap 17c 18.5c), -bitmap => '@'.Tk->findINC('demos/images/noletters'), qw(-tags item));
    $c->create(qw(bitmap 17c 21.5c), -bitmap => '@'.Tk->findINC('demos/images/letters'), qw(-tags item));

    $c->create(qw(text 25c 16.2c -text Windows -anchor n));
    my $c_button = $c->Button(-text => 'Press Me', -command => [sub {butPress(@_)}, $c, $red]);
    $c->create(qw(window 21c 18c), -window => $c_button, qw(-anchor nw -tags item));
    my $c_entry = $c->Entry(-width => '20', -relief => 'sunken');
    $c_entry->insert('end' => 'Edit this text');
    $c->create(qw(window 21c 21c), -window => $c_entry, qw(-anchor nw -tags item));
    my $c_scale = $c->Scale(-from => '0', -to => '100', '-length' => '6c', -sliderlength => '.4c', -width => '.5c',
			     -tickinterval => '0');
    $c->create(qw(window 28.5c 17.5c), -window => $c_scale, qw(-anchor n -tags item));
    $c->create(qw(text 21c 17.9c -text Button: -anchor sw));
    $c->create(qw(text 21c 20.9c -text Entry: -anchor sw));
    $c->create(qw(text 28.5c 17.4c -text Scale: -anchor s));

    # Set up event bindings for canvas.

    $c->bind('item', '<Any-Enter>' => sub {itemEnter(@_)});
    $c->bind('item', '<Any-Leave>' => sub {itemLeave(@_)});
    $c->Tk::bind('<1>' => sub {
	my($c) = @_;
        my $e = $c->XEvent;
	itemStartDrag $c, $e->x, $e->y;
    });
    $c->Tk::bind('<B1-Motion>' => sub {
	my($c) = @_;
        my $e = $c->XEvent;
	itemDrag $c, $e->x, $e->y;
    });
    $c->Tk::bind('<2>' => sub {
	my($c) = @_;
        my $e = $c->XEvent;
	$c->scan('mark', $e->x, $e->y);
    });
    $c->Tk::bind('<B2-Motion>' => sub {
	my ($c) = @_;
        my $e = $c->XEvent;
	$c->scan('dragto', $e->x, $e->y);
    });
    $c->Tk::bind('<3>' => sub {
	my($c) = @_;
        my $e = $c->XEvent;
	itemMark $c, $e->x, $e->y;
    });
    $c->Tk::bind('<B3-Motion>' => sub {
	my($c) = @_;
        my $e = $c->XEvent;
	itemStroke $c, $e->x, $e->y;
    });
    $c->Tk::bind('<Control-f>' => sub {
	my($c) = @_;
        my $e = $c->XEvent;
	itemsUnderArea $c;
    });
    $w->bind('<Any-Enter>' => [sub {
	my($w, $c) = @_;
        my $e = $c->XEvent;
	$c->Tk::focus;
    }, $c]);

} # end mkItems


1;
