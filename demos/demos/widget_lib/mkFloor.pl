
sub bg1;
sub bg2;
sub bg3;
sub fg1;
sub fg2;
sub fg3;
sub floorDisplay;
sub roomChanged;

sub mkFloor {

    # Create a top-level window containing a canvas that displays the floorplan for DEC's Western Research Laboratory.

    $mkFloor->destroy if Exists($mkFloor);
    $mkFloor = $top->Toplevel();
    my $w = $mkFloor;
    dpos $w;
    $w->title('Floorplan Canvas Demonstration');
    $w->iconname('Floorplan');
    $w->minsize(100, 100);

    my $w_msg = $w->Label(-font => '*-Times-Medium-R-Normal-*-180-*-*-*-*-*-*', -wraplength => '800',
			   -justify => 'left', -text => 'This window contains a canvas widget showing the floorplan of ' .
			   'Digital Equipment Corporation\'s Western Research Laboratory.  It has three levels.  At any ' .
			   'given time one of the levels is active, meaning that you can see its room structure.  To ' .
			   'activate a level, click the left mouse button anywhere on it.  As the mouse moves over the ' .
			   'active level, the room under the mouse lights up and its room number appears in the "Room:" ' .
			   'entry.  You can also type a room number in the entry and the room will light up.');
    my $w_frame2 = $w->Frame();
    my $w_ok = $w->Button(-text => 'OK', -width => 8, -command => ['destroy', $w]);
    $w_msg->pack(-side => 'top', -fill => 'both');
    $w_frame2->pack(-side => 'top', -fill => 'both', -expand => 'yes');
    $w_ok->pack(-side => 'bottom', -pady => '5');

    my $w_frame2_vscroll = $w_frame2->Scrollbar();
    my $w_frame2_hscroll = $w_frame2->Scrollbar(-orient => 'horiz');
    my $c = $w_frame2->Canvas(-width => '900', -height => '500', -xscrollcommand => ['set', $w_frame2_hscroll],
			-yscrollcommand => ['set', $w_frame2_vscroll], -relief => 'sunken', -bd =>2);
    $w_frame2_vscroll->configure(-command => ['yview', $c]);
    $w_frame2_hscroll->configure(-command => ['xview', $c]);
    $w_frame2_hscroll->pack(-side => 'bottom', -fill => 'x');
    $w_frame2_vscroll->pack(-side => 'right', -fill => 'y');
    $c->pack(-expand => 'yes', -fill => 'both');

    # Create an entry for displaying and typing in current room.

    $mkFloor::currentRoom = '';
    $mkFloor::c_entry = $c->Entry(-width => '10', -relief => 'sunken', -bd => '2', -textvariable => \$mkFloor::currentRoom);

    # Choose colors, then fill in the floorplan.

    if ($mkFloor->depth > 1) {
	$mkFloor::colors{'bg1'} = '#c0a3db55dc28';
	$mkFloor::colors{'outline1'} = '#70207f868000';
	$mkFloor::colors{'bg2'} = '#aeb8c6eec7ad';
	$mkFloor::colors{'outline2'} = '#59b466056666';
	$mkFloor::colors{'bg3'} = '#9cfab288b333';
	$mkFloor::colors{'outline3'} = '#43474c834ccd';
	$mkFloor::colors{'offices'} = 'Black';
	$mkFloor::colors{'active'} = '#dae0f278f332';
    } else {
	$mkFloor::colors{'bg1'} = 'white';
	$mkFloor::colors{'outline1'} = 'black';
	$mkFloor::colors{'bg2'} = 'white';
	$mkFloor::colors{'outline2'} = 'black';
	$mkFloor::colors{'bg3'} = 'white';
	$mkFloor::colors{'outline3'} = 'black';
	$mkFloor::colors{'offices'} = 'Black';
	$mkFloor::colors{'active'} = 'black';
    }
    $mkFloor::activeFloor = 0;
    floorDisplay $c, 3;

    # Set up event bindings for canvas.

    $c->bind('floor1', '<1>' => [sub {floorDisplay(@_)}, 1]);
    $c->bind('floor2', '<1>' => [sub {floorDisplay(@_)}, 2]);
    $c->bind('floor3', '<1>' => [sub {floorDisplay(@_)}, 3]);
    $c->bind('room', '<Enter>' => [sub {
	my($c, @args) = @_;
	my $id = $c->find('withtag' => 'current');
	$mkFloor::currentRoom  = $mkFloor::floorLabels{$c->find('withtag', 'current')} if defined $id;
	$c->idletasks;
    }]);
    $c->bind('room', '<Leave>' => sub {$mkFloor::currentRoom = ''});
    $c->Tk::bind('<2>' => sub {
	my($c) = @_;
        my $e = $c->XEvent;
	$c->scan('mark', $e->x, $e->y);
    });
    $c->Tk::bind('<B2-Motion>' => sub {
	my($c) = @_;
        my $e = $c->XEvent;
	$c->scan('dragto', $e->x, $e->y);
    });
#    $c->Tk::bind('<Destroy>' => sub {undef $mkFloor::currentRoom});
    $c->Tk::bind('<Enter>', => [sub {shift; shift->focus}, $mkFloor::c_entry]);
    tie($mkFloor::currentRoom, 'mkFloor', $mkFloor::currentRoom, $c); # trace currentRoom

} # end mkFloor


sub floorDisplay {

    # The following procedure recreates the floorplan display in the canvas given by "w".  The floor given by "active"
    # (1, 2, or 3) is displayed on top, with office structure visible.  (Used as a callback and a normal function.)

    my($w, $active, $e) = @_;
    my $e = $w->XEvent;

    return if $mkFloor::activeFloor eq $active;

    $w->delete('all');
    $mkFloor::activeFloor = $active;

    # First go through the three floors, displaying the backgrounds for each floor.

    bg1 $w, $mkFloor::colors{'bg1'}, $mkFloor::colors{'outline1'};
    bg2 $w, $mkFloor::colors{'bg2'}, $mkFloor::colors{'outline2'};
    bg3 $w, $mkFloor::colors{'bg3'}, $mkFloor::colors{'outline3'};

    # Raise the background for the active floor so that it's on top.

    $w->raise("floor${active}");

    # Create a dummy item just to mark this point in the display list, so we can insert highlights here.

    $w->create('rectangle', 0, 100, 1, 101, -fill => undef, -outline => undef, -tags => 'marker');

    # Add the walls and labels for the active floor, along with transparent polygons that define the rooms on the floor.
    # Make sure that the room polygons are on top.

    eval 'undef $mkFloor::floorLabels; undef $mkFloor::floorItems';
    my $cmd = "fg${active}";
    &$cmd($w, $mkFloor::colors{'offices'});
    $w->raise('room');

    # Offset the floors diagonally from each other.

    $w->move(qw(floor1 2c 2c));
    $w->move(qw(floor2 1c 1c));

    # Create items for the room entry and its label.

    $w->create('window', 600, 100, -anchor => 'w', -window => $mkFloor::c_entry);
    $w->create('text', 600, 100, -anchor => 'e', -text => 'Room: ');
    $w->configure(-scrollregion => [$w->bbox('all')]);

} # end floorDisplay


sub roomChanged {

    # Whenever the currentRoom variable changes, this procedure highlights the current room and unhighlights any previous room.

    my($w) = @_;

    $w->delete('highlight');
    return if not defined $mkFloor::floorItems{$mkFloor::currentRoom};
    $w->raise($w->create('polygon',  $w->coords($mkFloor::floorItems{$mkFloor::currentRoom}),
			 -fill => $mkFloor::colors{'active'}, -tags => 'highlight'), 'marker');

} # end roomChanged


# The following procedures are invoked to instantiate various portions of the building floorplan.  The bodies of these
# procedures were generated automatically from database files describing the building.


sub bg1 {

    my ($w, $fill, $outline) = @_;

    $w->create('poly', qw(347 80 349 82 351 84 353 85 363 92 375 99 386 104 386 129 398 129 398 162 484 162 484 129 559 129 559
	133 725 133 725 129 802 129 802 389 644 389 644 391 559 391 559 327 508 327 508 311 484 311 484 278 395 278 395 288 400
	288 404 288 409 290 413 292 418 297 421 302 422 309 421 318 417 325 411 330 405 332 397 333 344 333 340 334 336 336 335
	338 332 342 331 347 332 351 334 354 336 357 341 359 340 360 335 363 331 365 326 366 304 366 304 355 258 355 258 387 60
	387 60 391 0 391 0 337 3 337 3 114 8 114 8 25 30 25 30 5 93 5 98 5 104 7 110 10 116 16 119 20 122 28 123 32 123 68 220
	68 220 34 221 22 223 17 227 13 231 8 236 4 242 2 246 0 260 0 283 1 300 5 321 14 335 22 348 25 365 29 363 39 358 48 352
	56 337 70 344 76 347 80), -tags => ['floor1', 'bg'], -fill => $fill);

    $w->create('line', qw(386 129 398 129), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(258 355 258 387), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(60 387 60 391), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(0 337 0 391), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(60 391 0 391), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(3 114 3 337), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(258 387 60 387), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(484 162 398 162), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(398 162 398 129), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(484 278 484 311), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(484 311 508 311), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(508 327 508 311), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(559 327 508 327), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(644 391 559 391), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(644 389 644 391), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(559 129 484 129), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(484 162 484 129), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(725 133 559 133), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(559 129 559 133), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(725 129 802 129), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(802 389 802 129), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(3 337 0 337), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(559 391 559 327), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(802 389 644 389), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(725 133 725 129), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(8 25 8 114), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(8 114 3 114), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(30 25 8 25), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(484 278 395 278), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(30 25 30 5), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(93 5 30 5), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(98 5 93 5), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(104 7 98 5), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(110 10 104 7), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(116 16 110 10), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(119 20 116 16), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(122 28 119 20), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(123 32 122 28), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(123 68 123 32), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(220 68 123 68), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(386 129 386 104), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(386 104 375 99), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(375 99 363 92), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(353 85 363 92), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(220 68 220 34), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(337 70 352 56), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(352 56 358 48), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(358 48 363 39), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(363 39 365 29), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(365 29 348 25), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(348 25 335 22), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(335 22 321 14), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(321 14 300 5), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(300 5 283 1), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(283 1 260 0), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(260 0 246 0), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(246 0 242 2), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(242 2 236 4), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(236 4 231 8), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(231 8 227 13), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(223 17 227 13), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(221 22 223 17), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(220 34 221 22), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(340 360 335 363), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(335 363 331 365), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(331 365 326 366), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(326 366 304 366), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(304 355 304 366), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(395 288 400 288), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(404 288 400 288), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(409 290 404 288), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(413 292 409 290), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(418 297 413 292), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(421 302 418 297), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(422 309 421 302), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(421 318 422 309), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(421 318 417 325), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(417 325 411 330), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(411 330 405 332), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(405 332 397 333), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(397 333 344 333), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(344 333 340 334), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(340 334 336 336), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(336 336 335 338), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(335 338 332 342), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(331 347 332 342), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(332 351 331 347), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(334 354 332 351), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(336 357 334 354), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(341 359 336 357), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(341 359 340 360), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(395 288 395 278), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(304 355 258 355), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(347 80 344 76), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(344 76 337 70), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(349 82 347 80), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(351 84 349 82), -fill => $outline, -tags => ['floor1', 'bg']);
    $w->create('line', qw(353 85 351 84), -fill => $outline, -tags => ['floor1', 'bg']);

} # end bg1


sub bg2 {

    my ($w, $fill, $outline) = @_;

    $w->create('poly', qw(559 129 484 129 484 162 398 162 398 129 315 129 315 133 176 133 176 129 96 129 96 133 3 133 3 339 0
	339 0 391 60 391 60 387 258 387 258 329 350 329 350 311 395 311 395 280 484 280 484 311 508 311 508 327 558 327 558 391
	644 391 644 367 802 367 802 129 725 129 725 133 559 133 559 129), -tags => ['floor2', 'bg'], -fill => $fill);
    $w->create('line', qw(350 311 350 329), -fill => $outline, -tags => ['floor2', 'bg']);
    $w->create('line', qw(398 129 398 162), -fill => $outline, -tags => ['floor2', 'bg']);
    $w->create('line', qw(802 367 802 129), -fill => $outline, -tags => ['floor2', 'bg']);
    $w->create('line', qw(802 129 725 129), -fill => $outline, -tags => ['floor2', 'bg']);
    $w->create('line', qw(725 133 725 129), -fill => $outline, -tags => ['floor2', 'bg']);
    $w->create('line', qw(559 129 559 133), -fill => $outline, -tags => ['floor2', 'bg']);
    $w->create('line', qw(559 133 725 133), -fill => $outline, -tags => ['floor2', 'bg']);
    $w->create('line', qw(484 162 484 129), -fill => $outline, -tags => ['floor2', 'bg']);
    $w->create('line', qw(559 129 484 129), -fill => $outline, -tags => ['floor2', 'bg']);
    $w->create('line', qw(802 367 644 367), -fill => $outline, -tags => ['floor2', 'bg']);
    $w->create('line', qw(644 367 644 391), -fill => $outline, -tags => ['floor2', 'bg']);
    $w->create('line', qw(644 391 558 391), -fill => $outline, -tags => ['floor2', 'bg']);
    $w->create('line', qw(558 327 558 391), -fill => $outline, -tags => ['floor2', 'bg']);
    $w->create('line', qw(558 327 508 327), -fill => $outline, -tags => ['floor2', 'bg']);
    $w->create('line', qw(508 327 508 311), -fill => $outline, -tags => ['floor2', 'bg']);
    $w->create('line', qw(484 311 508 311), -fill => $outline, -tags => ['floor2', 'bg']);
    $w->create('line', qw(484 280 484 311), -fill => $outline, -tags => ['floor2', 'bg']);
    $w->create('line', qw(398 162 484 162), -fill => $outline, -tags => ['floor2', 'bg']);
    $w->create('line', qw(484 280 395 280), -fill => $outline, -tags => ['floor2', 'bg']);
    $w->create('line', qw(395 280 395 311), -fill => $outline, -tags => ['floor2', 'bg']);
    $w->create('line', qw(258 387 60 387), -fill => $outline, -tags => ['floor2', 'bg']);
    $w->create('line', qw(3 133 3 339), -fill => $outline, -tags => ['floor2', 'bg']);
    $w->create('line', qw(3 339 0 339), -fill => $outline, -tags => ['floor2', 'bg']);
    $w->create('line', qw(60 391 0 391), -fill => $outline, -tags => ['floor2', 'bg']);
    $w->create('line', qw(0 339 0 391), -fill => $outline, -tags => ['floor2', 'bg']);
    $w->create('line', qw(60 387 60 391), -fill => $outline, -tags => ['floor2', 'bg']);
    $w->create('line', qw(258 329 258 387), -fill => $outline, -tags => ['floor2', 'bg']);
    $w->create('line', qw(350 329 258 329), -fill => $outline, -tags => ['floor2', 'bg']);
    $w->create('line', qw(395 311 350 311), -fill => $outline, -tags => ['floor2', 'bg']);
    $w->create('line', qw(398 129 315 129), -fill => $outline, -tags => ['floor2', 'bg']);
    $w->create('line', qw(176 133 315 133), -fill => $outline, -tags => ['floor2', 'bg']);
    $w->create('line', qw(176 129 96 129), -fill => $outline, -tags => ['floor2', 'bg']);
    $w->create('line', qw(3 133 96 133), -fill => $outline, -tags => ['floor2', 'bg']);
    $w->create('line', qw(315 133 315 129), -fill => $outline, -tags => ['floor2', 'bg']);
    $w->create('line', qw(176 133 176 129), -fill => $outline, -tags => ['floor2', 'bg']);
    $w->create('line', qw(96 133 96 129), -fill => $outline, -tags => ['floor2', 'bg']);

} # end bg2


sub bg3 {

    my ($w, $fill, $outline) = @_;

    $w->create('poly', qw(159 300 107 300 107 248 159 248 159 129 96 129 96 133 21 133 21 331 0 331 0 391 60 391 60 370 159 370
	159 300), -tags => ['floor3', 'bg'], -fill => $fill);
    $w->create('poly', qw(258 370 258 329 350 329 350 311 399 311 399 129 315 129 315 133 176 133 176 129 159 129 159 370 258
	370), -tags =>['floor3', 'bg'], -fill => $fill);
    $w->create('line', qw(96 133 96 129), -fill => $outline, -tags => ['floor3', 'bg']);
    $w->create('line', qw(176 129 96 129), -fill => $outline, -tags => ['floor3', 'bg']);
    $w->create('line', qw(176 129 176 133), -fill => $outline, -tags => ['floor3', 'bg']);
    $w->create('line', qw(315 133 176 133), -fill => $outline, -tags => ['floor3', 'bg']);
    $w->create('line', qw(315 133 315 129), -fill => $outline, -tags => ['floor3', 'bg']);
    $w->create('line', qw(399 129 315 129), -fill => $outline, -tags => ['floor3', 'bg']);
    $w->create('line', qw(399 311 399 129), -fill => $outline, -tags => ['floor3', 'bg']);
    $w->create('line', qw(399 311 350 311), -fill => $outline, -tags => ['floor3', 'bg']);
    $w->create('line', qw(350 329 350 311), -fill => $outline, -tags => ['floor3', 'bg']);
    $w->create('line', qw(350 329 258 329), -fill => $outline, -tags => ['floor3', 'bg']);
    $w->create('line', qw(258 370 258 329), -fill => $outline, -tags => ['floor3', 'bg']);
    $w->create('line', qw(60 370 258 370), -fill => $outline, -tags => ['floor3', 'bg']);
    $w->create('line', qw(60 370 60 391), -fill => $outline, -tags => ['floor3', 'bg']);
    $w->create('line', qw(60 391 0 391), -fill => $outline, -tags => ['floor3', 'bg']);
    $w->create('line', qw(0 391 0 331), -fill => $outline, -tags => ['floor3', 'bg']);
    $w->create('line', qw(21 331 0 331), -fill => $outline, -tags => ['floor3', 'bg']);
    $w->create('line', qw(21 331 21 133), -fill => $outline, -tags => ['floor3', 'bg']);
    $w->create('line', qw(96 133 21 133), -fill => $outline, -tags => ['floor3', 'bg']);
    $w->create('line', qw(107 300 159 300 159 248 107 248 107 300), -fill => $outline, -tags => ['floor3', 'bg']);

} # end bg3


sub fg1 {

    my($w, $color) = @_;

    my($i);
    $i = $w->create('polygon', qw(375 246 375 172 341 172 341 246), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = 101;
    $mkFloor::floorItems{'101'} = $i;
    $w->create('text', qw(358 209), -text => '101', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(307 240 339 240 339 206 307 206), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = 'Pub Lift1';
    $mkFloor::floorItems{'Pub Lift1'} = $i;
    $w->create('text', qw(323 223), -text => 'Pub Lift1', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(339 205 307 205 307 171 339 171), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = 'Priv Lift1';
    $mkFloor::floorItems{'Priv Lift1'} = $i;
    $w->create('text', qw(323 188), -text => 'Priv Lift1', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(42 389 42 337 1 337 1 389), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = 110;
    $mkFloor::floorItems{'110'} = $i;
    $w->create('text', qw(21.5 363), -text => '110', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(59 389 59 385 90 385 90 337 44 337 44 389), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = 109;
    $mkFloor::floorItems{'109'} = $i;
    $w->create('text', qw(67 363), -text => '109', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(51 300 51 253 6 253 6 300), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = 111;
    $mkFloor::floorItems{'111'} = $i;
    $w->create('text', qw(28.5 276.5), -text => '111', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(98 248 98 309 79 309 79 248), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = '117B';
    $mkFloor::floorItems{'117B'} = $i;
    $w->create('text', qw(88.5 278.5), -text => '117B', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(51 251 51 204 6 204 6 251), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = 112;
    $mkFloor::floorItems{'112'} = $i;
    $w->create('text', qw(28.5 227.5), -text => '112', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(6 156 51 156 51 203 6 203), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = 113;
    $mkFloor::floorItems{'113'} = $i;
    $w->create('text', qw(28.5 179.5), -text => '113', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(85 169 79 169 79 192 85 192), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = '117A';
    $mkFloor::floorItems{'117A'} = $i;
    $w->create('text', qw(82 180.5), -text => '117A', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(77 302 77 168 53 168 53 302), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = 117;
    $mkFloor::floorItems{'117'} = $i;
    $w->create('text', qw(65 235), -text => '117', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(51 155 51 115 6 115 6 155), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = 114;
    $mkFloor::floorItems{'114'} = $i;
    $w->create('text', qw(28.5 135), -text => '114', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(95 115 53 115 53 168 95 168), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = 115;
    $mkFloor::floorItems{'115'} = $i;
    $w->create('text', qw(74 141.5), -text => '115', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(87 113 87 27 10 27 10 113), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = 116;
    $mkFloor::floorItems{'116'} = $i;
    $w->create('text', qw(48.5 70), -text => '116', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(89 91 128 91 128 113 89 113), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = 118;
    $mkFloor::floorItems{'118'} = $i;
    $w->create('text', qw(108.5 102), -text => '118', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(178 128 178 132 216 132 216 91 163 91 163 112 149 112 149 128), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = 120;
    $mkFloor::floorItems{'120'} = $i;
    $w->create('text', qw(189.5 111.5), -text => '120', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(79 193 87 193 87 169 136 169 136 192 156 192 156 169 175 169 175 246 79 246), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = 122;
    $mkFloor::floorItems{'122'} = $i;
    $w->create('text', qw(131 207.5), -text => '122', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(138 169 154 169 154 191 138 191), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = 121;
    $mkFloor::floorItems{'121'} = $i;
    $w->create('text', qw(146 180), -text => '121', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(99 300 126 300 126 309 99 309), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = '106A';
    $mkFloor::floorItems{'106A'} = $i;
    $w->create('text', qw(112.5 304.5), -text => '106A', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(128 299 128 309 150 309 150 248 99 248 99 299), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = 105;
    $mkFloor::floorItems{'105'} = $i;
    $w->create('text', qw(124.5 278.5), -text => '105', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(174 309 174 300 152 300 152 309), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = '106B';
    $mkFloor::floorItems{'106B'} = $i;
    $w->create('text', qw(163 304.5), -text => '106B', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(176 299 176 309 216 309 216 248 152 248 152 299), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = 104;
    $mkFloor::floorItems{'104'} = $i;
    $w->create('text', qw(184 278.5), -text => '104', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(138 385 138 337 91 337 91 385), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = 108;
    $mkFloor::floorItems{'108'} = $i;
    $w->create('text', qw(114.5 361), -text => '108', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(256 337 140 337 140 385 256 385), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = 107;
    $mkFloor::floorItems{'107'} = $i;
    $w->create('text', qw(198 361), -text => '107', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(300 353 300 329 260 329 260 353), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = 'Smoking';
    $mkFloor::floorItems{'Smoking'} = $i;
    $w->create('text', qw(280 341), -text => 'Smoking', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(314 135 314 170 306 170 306 246 177 246 177 135), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = 123;
    $mkFloor::floorItems{'123'} = $i;
    $w->create('text', qw(245.5 190.5), -text => '123', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(217 248 301 248 301 326 257 326 257 310 217 310), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = 103;
    $mkFloor::floorItems{'103'} = $i;
    $w->create('text', qw(259 287), -text => '103', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(396 188 377 188 377 169 316 169 316 131 396 131), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = 124;
    $mkFloor::floorItems{'124'} = $i;
    $w->create('text', qw(356 150), -text => '124', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(397 226 407 226 407 189 377 189 377 246 397 246), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = 125;
    $mkFloor::floorItems{'125'} = $i;
    $w->create('text', qw(392 217.5), -text => '125', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(399 187 409 187 409 207 474 207 474 164 399 164), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = 126;
    $mkFloor::floorItems{'126'} = $i;
    $w->create('text', qw(436.5 185.5), -text => '126', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(409 209 409 229 399 229 399 253 486 253 486 239 474 239 474 209), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = 127;
    $mkFloor::floorItems{'127'} = $i;
    $w->create('text', qw(436.5 231), -text => '127', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(501 164 501 174 495 174 495 188 490 188 490 204 476 204 476 164), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = 'MShower';
    $mkFloor::floorItems{'MShower'} = $i;
    $w->create('text', qw(488.5 184), -text => 'MShower', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(497 176 513 176 513 204 492 204 492 190 497 190), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = 'Closet';
    $mkFloor::floorItems{'Closet'} = $i;
    $w->create('text', qw(502.5 190), -text => 'Closet', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(476 237 476 206 513 206 513 254 488 254 488 237), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = 'WShower';
    $mkFloor::floorItems{'WShower'} = $i;
    $w->create('text', qw(494.5 230), -text => 'WShower', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(486 131 558 131 558 135 724 135 724 166 697 166 697 275 553 275 531 254 515 254 515 174 503 174 503 161 486 161), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = 130;
    $mkFloor::floorItems{'130'} = $i;
    $w->create('text', qw(638.5 205), -text => '130', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(308 242 339 242 339 248 342 248 342 246 397 246 397 276 393 276 393 309 300 309 300 248 308 248), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = 102;
    $mkFloor::floorItems{'102'} = $i;
    $w->create('text', qw(367.5 278.5), -text => '102', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(397 255 486 255 486 276 397 276), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = 128;
    $mkFloor::floorItems{'128'} = $i;
    $w->create('text', qw(441.5 265.5), -text => '128', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(510 309 486 309 486 255 530 255 552 277 561 277 561 325 510 325), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = 129;
    $mkFloor::floorItems{'129'} = $i;
    $w->create('text', qw(535.5 293), -text => '129', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(696 281 740 281 740 387 642 387 642 389 561 389 561 277 696 277), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = 133;
    $mkFloor::floorItems{'133'} = $i;
    $w->create('text', qw(628.5 335), -text => '133', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(742 387 742 281 800 281 800 387), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = 132;
    $mkFloor::floorItems{'132'} = $i;
    $w->create('text', qw(771 334), -text => '132', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(800 168 800 280 699 280 699 168), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = 134;
    $mkFloor::floorItems{'134'} = $i;
    $w->create('text', qw(749.5 224), -text => '134', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(726 131 726 166 800 166 800 131), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = 135;
    $mkFloor::floorItems{'135'} = $i;
    $w->create('text', qw(763 148.5), -text => '135', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(340 360 335 363 331 365 326 366 304 366 304 312 396 312 396 288 400 288 404 288 409 290 413 292 418 297 421 302 422 309 421 318 417 325 411 330 405 332 397 333 344 333 340 334 336 336 335 338 332 342 331 347 332 351 334 354 336 357 341 359), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = 'Ramona Stair';
    $mkFloor::floorItems{'Ramona Stair'} = $i;
    $w->create('text', qw(368 323), -text => 'Ramona Stair', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(30 23 30 5 93 5 98 5 104 7 110 10 116 16 119 20 122 28 123 32 123 68 220 68 220 87 90 87 90 23), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = 'University Stair';
    $mkFloor::floorItems{'University Stair'} = $i;
    $w->create('text', qw(155 77.5), -text => 'University Stair', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(282 37 295 40 312 49 323 56 337 70 352 56 358 48 363 39 365 29 348 25 335 22 321 14 300 5 283 1 260 0 246 0 242 2 236 4 231 8 227 13 223 17 221 22 220 34 260 34), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = 'Plaza Stair';
    $mkFloor::floorItems{'Plaza Stair'} = $i;
    $w->create('text', qw(317.5 28.5), -text => 'Plaza Stair', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(220 34 260 34 282 37 295 40 312 49 323 56 337 70 350 83 365 94 377 100 386 104 386 128 220 128), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = 'Plaza Deck';
    $mkFloor::floorItems{'Plaza Deck'} = $i;
    $w->create('text', qw(303 81), -text => 'Plaza Deck', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(257 336 77 336 6 336 6 301 77 301 77 310 257 310), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = 106;
    $mkFloor::floorItems{'106'} = $i;
    $w->create('text', qw(131.5 318.5), -text => '106', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $i = $w->create('polygon', qw(146 110 162 110 162 91 130 91 130 115 95 115 95 128 114 128 114 151 157 151 157 153 112 153 112 130 97 130 97 168 175 168 175 131 146 131), -fill => undef, -tags => ['floor1', 'room']);
    $mkFloor::floorLabels{$i} = 119;
    $mkFloor::floorItems{'119'} = $i;
    $w->create('text', qw(143.5 133), -text => '119', -fill => $color, -anchor => 'c', -tags => ['floor1', 'label']);
    $w->create('line', qw(155 191 155 189), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(155 177 155 169), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(96 129 96 169), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(78 169 176 169), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(176 247 176 129), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(340 206 307 206), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(340 187 340 170), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(340 210 340 201), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(340 247 340 224), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(340 241 307 241), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(376 246 376 170), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(307 247 307 170), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(376 170 307 170), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(315 129 315 170), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(147 129 176 129), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(202 133 176 133), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(398 129 315 129), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(258 352 258 387), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(60 387 60 391), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(0 337 0 391), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(60 391 0 391), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(3 114 3 337), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(258 387 60 387), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(52 237 52 273), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(52 189 52 225), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(52 140 52 177), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(395 306 395 311), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(531 254 398 254), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(475 178 475 238), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(502 162 398 162), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(398 129 398 188), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(383 188 376 188), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(408 188 408 194), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(398 227 398 254), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(408 227 398 227), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(408 222 408 227), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(408 206 408 210), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(408 208 475 208), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(484 278 484 311), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(484 311 508 311), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(508 327 508 311), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(559 327 508 327), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(644 391 559 391), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(644 389 644 391), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(514 205 475 205), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(496 189 496 187), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(559 129 484 129), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(484 162 484 129), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(725 133 559 133), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(559 129 559 133), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(725 149 725 167), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(725 129 802 129), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(802 389 802 129), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(739 167 802 167), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(396 188 408 188), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(0 337 9 337), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(58 337 21 337), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(43 391 43 337), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(105 337 75 337), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(91 387 91 337), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(154 337 117 337), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(139 387 139 337), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(227 337 166 337), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(258 337 251 337), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(258 328 302 328), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(302 355 302 311), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(395 311 302 311), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(484 278 395 278), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(395 294 395 278), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(473 278 473 275), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(473 256 473 254), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(533 257 531 254), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(553 276 551 274), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(698 276 553 276), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(559 391 559 327), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(802 389 644 389), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(741 314 741 389), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(698 280 698 167), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(707 280 698 280), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(802 280 731 280), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(741 280 741 302), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(698 167 727 167), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(725 137 725 129), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(514 254 514 175), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(496 175 514 175), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(502 175 502 162), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(475 166 475 162), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(496 176 496 175), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(491 189 496 189), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(491 205 491 189), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(487 238 475 238), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(487 240 487 238), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(487 252 487 254), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(315 133 304 133), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(256 133 280 133), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(78 247 270 247), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(307 247 294 247), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(214 133 232 133), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(217 247 217 266), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(217 309 217 291), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(217 309 172 309), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(154 309 148 309), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(175 300 175 309), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(151 300 175 300), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(151 247 151 309), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(78 237 78 265), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(78 286 78 309), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(106 309 78 309), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(130 309 125 309), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(99 309 99 247), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(127 299 99 299), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(127 309 127 299), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(155 191 137 191), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(137 169 137 191), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(78 171 78 169), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(78 190 78 218), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(86 192 86 169), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(86 192 78 192), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(52 301 3 301), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(52 286 52 301), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(52 252 3 252), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(52 203 3 203), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(3 156 52 156), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(8 25 8 114), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(63 114 3 114), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(75 114 97 114), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(108 114 129 114), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(129 114 129 89), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(52 114 52 128), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(132 89 88 89), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(88 25 88 89), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(88 114 88 89), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(218 89 144 89), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(147 111 147 129), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(162 111 147 111), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(162 109 162 111), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(162 96 162 89), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(218 89 218 94), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(218 89 218 119), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(8 25 88 25), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(258 337 258 328), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(113 129 96 129), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(302 355 258 355), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(386 104 386 129), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(377 100 386 104), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(365 94 377 100), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(350 83 365 94), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(337 70 350 83), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(337 70 323 56), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(312 49 323 56), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(295 40 312 49), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(282 37 295 40), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(260 34 282 37), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(253 34 260 34), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(386 128 386 104), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(113 152 156 152), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(113 152 156 152), -fill => $color, -tags => ['floor1', 'wall']);
    $w->create('line', qw(113 152 113 129), -fill => $color, -tags => ['floor1', 'wall']);

} # end fg1;


sub fg2 {;

    my($w, $color) = @_;

    my($i);
    $i = $w->create('polygon', qw(748 188 755 188 755 205 758 205 758 222 800 222 800 168 748 168), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 238;
    $mkFloor::floorItems{'238'} = $i;
    $w->create('text', qw(774 195), -text => '238', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(726 188 746 188 746 166 800 166 800 131 726 131), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 237;
    $mkFloor::floorItems{'237'} = $i;
    $w->create('text', qw(763 148.5), -text => '237', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(497 187 497 204 559 204 559 324 641 324 643 324 643 291 641 291 641 205 696 205 696 291 694 291 694 314 715 314 715 291 715 205 755 205 755 190 724 190 724 187), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 246;
    $mkFloor::floorItems{'246'} = $i;
    $w->create('text', qw(600 264), -text => '246', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(694 279 643 279 643 314 694 314), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 247;
    $mkFloor::floorItems{'247'} = $i;
    $w->create('text', qw(668.5 296.5), -text => '247', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(232 250 308 250 308 242 339 242 339 246 397 246 397 255 476 255 476 250 482 250 559 250 559 274 482 274 482 278 396 278 396 274 232 274), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 202;
    $mkFloor::floorItems{'202'} = $i;
    $w->create('text', qw(285.5 260), -text => '202', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(53 228 53 338 176 338 233 338 233 196 306 196 306 180 175 180 175 169 156 169 156 196 176 196 176 228), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 206;
    $mkFloor::floorItems{'206'} = $i;
    $w->create('text', qw(143 267), -text => '206', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(51 277 6 277 6 338 51 338), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 212;
    $mkFloor::floorItems{'212'} = $i;
    $w->create('text', qw(28.5 307.5), -text => '212', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(557 276 486 276 486 309 510 309 510 325 557 325), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 245;
    $mkFloor::floorItems{'245'} = $i;
    $w->create('text', qw(521.5 300.5), -text => '245', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(560 389 599 389 599 326 560 326), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 244;
    $mkFloor::floorItems{'244'} = $i;
    $w->create('text', qw(579.5 357.5), -text => '244', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(601 389 601 326 643 326 643 389), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 243;
    $mkFloor::floorItems{'243'} = $i;
    $w->create('text', qw(622 357.5), -text => '243', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(688 316 645 316 645 365 688 365), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 242;
    $mkFloor::floorItems{'242'} = $i;
    $w->create('text', qw(666.5 340.5), -text => '242', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(802 367 759 367 759 226 802 226), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 'Barbecue Deck';
    $mkFloor::floorItems{'Barbecue Deck'} = $i;
    $w->create('text', qw(780.5 296.5), -text => 'Barbecue Deck', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(755 262 755 314 717 314 717 262), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 240;
    $mkFloor::floorItems{'240'} = $i;
    $w->create('text', qw(736 288), -text => '240', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(755 316 689 316 689 365 755 365), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 241;
    $mkFloor::floorItems{'241'} = $i;
    $w->create('text', qw(722 340.5), -text => '241', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(755 206 717 206 717 261 755 261), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 239;
    $mkFloor::floorItems{'239'} = $i;
    $w->create('text', qw(736 233.5), -text => '239', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(695 277 643 277 643 206 695 206), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 248;
    $mkFloor::floorItems{'248'} = $i;
    $w->create('text', qw(669 241.5), -text => '248', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(676 135 676 185 724 185 724 135), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 236;
    $mkFloor::floorItems{'236'} = $i;
    $w->create('text', qw(700 160), -text => '236', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(675 135 635 135 635 145 628 145 628 185 675 185), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 235;
    $mkFloor::floorItems{'235'} = $i;
    $w->create('text', qw(651.5 160), -text => '235', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(626 143 633 143 633 135 572 135 572 143 579 143 579 185 626 185), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 234;
    $mkFloor::floorItems{'234'} = $i;
    $w->create('text', qw(606 160), -text => '234', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(557 135 571 135 571 145 578 145 578 185 527 185 527 131 557 131), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 233;
    $mkFloor::floorItems{'233'} = $i;
    $w->create('text', qw(552.5 158), -text => '233', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(476 249 557 249 557 205 476 205), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 230;
    $mkFloor::floorItems{'230'} = $i;
    $w->create('text', qw(516.5 227), -text => '230', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(476 164 486 164 486 131 525 131 525 185 476 185), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 232;
    $mkFloor::floorItems{'232'} = $i;
    $w->create('text', qw(500.5 158), -text => '232', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(476 186 495 186 495 204 476 204), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 229;
    $mkFloor::floorItems{'229'} = $i;
    $w->create('text', qw(485.5 195), -text => '229', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(474 207 409 207 409 187 399 187 399 164 474 164), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 227;
    $mkFloor::floorItems{'227'} = $i;
    $w->create('text', qw(436.5 185.5), -text => '227', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(399 228 399 253 474 253 474 209 409 209 409 228), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 228;
    $mkFloor::floorItems{'228'} = $i;
    $w->create('text', qw(436.5 231), -text => '228', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(397 246 397 226 407 226 407 189 377 189 377 246), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 226;
    $mkFloor::floorItems{'226'} = $i;
    $w->create('text', qw(392 217.5), -text => '226', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(377 169 316 169 316 131 397 131 397 188 377 188), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 225;
    $mkFloor::floorItems{'225'} = $i;
    $w->create('text', qw(356.5 150), -text => '225', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(234 198 306 198 306 249 234 249), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 224;
    $mkFloor::floorItems{'224'} = $i;
    $w->create('text', qw(270 223.5), -text => '224', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(270 179 306 179 306 170 314 170 314 135 270 135), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 223;
    $mkFloor::floorItems{'223'} = $i;
    $w->create('text', qw(292 157), -text => '223', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(268 179 221 179 221 135 268 135), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 222;
    $mkFloor::floorItems{'222'} = $i;
    $w->create('text', qw(244.5 157), -text => '222', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(177 179 219 179 219 135 177 135), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 221;
    $mkFloor::floorItems{'221'} = $i;
    $w->create('text', qw(198 157), -text => '221', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(299 327 349 327 349 284 341 284 341 276 299 276), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 204;
    $mkFloor::floorItems{'204'} = $i;
    $w->create('text', qw(324 301.5), -text => '204', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(234 276 297 276 297 327 257 327 257 338 234 338), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 205;
    $mkFloor::floorItems{'205'} = $i;
    $w->create('text', qw(265.5 307), -text => '205', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(256 385 256 340 212 340 212 385), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 207;
    $mkFloor::floorItems{'207'} = $i;
    $w->create('text', qw(234 362.5), -text => '207', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(210 340 164 340 164 385 210 385), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 208;
    $mkFloor::floorItems{'208'} = $i;
    $w->create('text', qw(187 362.5), -text => '208', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(115 340 162 340 162 385 115 385), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 209;
    $mkFloor::floorItems{'209'} = $i;
    $w->create('text', qw(138.5 362.5), -text => '209', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(89 228 89 156 53 156 53 228), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 217;
    $mkFloor::floorItems{'217'} = $i;
    $w->create('text', qw(71 192), -text => '217', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(89 169 97 169 97 190 89 190), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = '217A';
    $mkFloor::floorItems{'217A'} = $i;
    $w->create('text', qw(93 179.5), -text => '217A', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(89 156 89 168 95 168 95 135 53 135 53 156), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 216;
    $mkFloor::floorItems{'216'} = $i;
    $w->create('text', qw(71 145.5), -text => '216', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(51 179 51 135 6 135 6 179), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 215;
    $mkFloor::floorItems{'215'} = $i;
    $w->create('text', qw(28.5 157), -text => '215', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(51 227 6 227 6 180 51 180), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 214;
    $mkFloor::floorItems{'214'} = $i;
    $w->create('text', qw(28.5 203.5), -text => '214', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(51 275 6 275 6 229 51 229), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 213;
    $mkFloor::floorItems{'213'} = $i;
    $w->create('text', qw(28.5 252), -text => '213', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(114 340 67 340 67 385 114 385), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 210;
    $mkFloor::floorItems{'210'} = $i;
    $w->create('text', qw(90.5 362.5), -text => '210', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(59 389 59 385 65 385 65 340 1 340 1 389), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 211;
    $mkFloor::floorItems{'211'} = $i;
    $w->create('text', qw(33 364.5), -text => '211', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(393 309 350 309 350 282 342 282 342 276 393 276), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 203;
    $mkFloor::floorItems{'203'} = $i;
    $w->create('text', qw(367.5 292.5), -text => '203', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(99 191 91 191 91 226 174 226 174 198 154 198 154 192 109 192 109 169 99 169), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 220;
    $mkFloor::floorItems{'220'} = $i;
    $w->create('text', qw(132.5 208.5), -text => '220', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(339 205 307 205 307 171 339 171), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 'Priv Lift2';
    $mkFloor::floorItems{'Priv Lift2'} = $i;
    $w->create('text', qw(323 188), -text => 'Priv Lift2', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(307 240 339 240 339 206 307 206), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 'Pub Lift2';
    $mkFloor::floorItems{'Pub Lift2'} = $i;
    $w->create('text', qw(323 223), -text => 'Pub Lift2', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(175 168 97 168 97 131 175 131), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 218;
    $mkFloor::floorItems{'218'} = $i;
    $w->create('text', qw(136 149.5), -text => '218', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(154 191 111 191 111 169 154 169), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 219;
    $mkFloor::floorItems{'219'} = $i;
    $w->create('text', qw(132.5 180), -text => '219', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $i = $w->create('polygon', qw(375 246 375 172 341 172 341 246), -fill => undef, -tags => ['floor2', 'room']);
    $mkFloor::floorLabels{$i} = 201;
    $mkFloor::floorItems{'201'} = $i;
    $w->create('text', qw(358 209), -text => '201', -fill => $color, -anchor => 'c', -tags => ['floor2', 'label']);
    $w->create('line', qw(641 186 678 186), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(757 350 757 367), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(634 133 634 144), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(634 144 627 144), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(572 133 572 144), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(572 144 579 144), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(398 129 398 162), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(174 197 175 197), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(175 197 175 227), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(757 206 757 221), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(396 188 408 188), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(727 189 725 189), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(747 167 802 167), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(747 167 747 189), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(755 189 739 189), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(769 224 757 224), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(802 224 802 129), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(802 129 725 129), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(725 189 725 129), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(725 186 690 186), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(676 133 676 186), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(627 144 627 186), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(629 186 593 186), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(579 144 579 186), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(559 129 559 133), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(725 133 559 133), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(484 162 484 129), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(559 129 484 129), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(526 129 526 186), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(540 186 581 186), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(528 186 523 186), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(511 186 475 186), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(496 190 496 186), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(496 205 496 202), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(475 205 527 205), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(558 205 539 205), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(558 205 558 249), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(558 249 475 249), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(662 206 642 206), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(695 206 675 206), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(695 278 642 278), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(642 291 642 206), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(695 291 695 206), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(716 208 716 206), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(757 206 716 206), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(757 221 757 224), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(793 224 802 224), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(757 262 716 262), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(716 220 716 264), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(716 315 716 276), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(757 315 703 315), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(757 325 757 224), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(757 367 644 367), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(689 367 689 315), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(647 315 644 315), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(659 315 691 315), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(600 325 600 391), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(627 325 644 325), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(644 391 644 315), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(615 325 575 325), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(644 391 558 391), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(563 325 558 325), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(558 391 558 314), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(558 327 508 327), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(558 275 484 275), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(558 302 558 275), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(508 327 508 311), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(484 311 508 311), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(484 275 484 311), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(475 208 408 208), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(408 206 408 210), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(408 222 408 227), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(408 227 398 227), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(398 227 398 254), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(408 188 408 194), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(383 188 376 188), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(398 188 398 162), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(398 162 484 162), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(475 162 475 254), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(398 254 475 254), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(484 280 395 280), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(395 311 395 275), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(307 197 293 197), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(278 197 233 197), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(233 197 233 249), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(307 179 284 179), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(233 249 278 249), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(269 179 269 133), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(220 179 220 133), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(155 191 110 191), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(90 190 98 190), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(98 169 98 190), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(52 133 52 165), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(52 214 52 177), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(52 226 52 262), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(52 274 52 276), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(234 275 234 339), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(226 339 258 339), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(211 387 211 339), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(214 339 177 339), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(258 387 60 387), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(3 133 3 339), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(165 339 129 339), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(117 339 80 339), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(68 339 59 339), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(0 339 46 339), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(60 391 0 391), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(0 339 0 391), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(60 387 60 391), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(258 329 258 387), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(350 329 258 329), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(395 311 350 311), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(398 129 315 129), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(176 133 315 133), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(176 129 96 129), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(3 133 96 133), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(66 387 66 339), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(115 387 115 339), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(163 387 163 339), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(234 275 276 275), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(288 275 309 275), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(298 275 298 329), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(341 283 350 283), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(321 275 341 275), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(375 275 395 275), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(315 129 315 170), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(376 170 307 170), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(307 250 307 170), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(376 245 376 170), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(340 241 307 241), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(340 245 340 224), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(340 210 340 201), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(340 187 340 170), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(340 206 307 206), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(293 250 307 250), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(271 179 238 179), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(226 179 195 179), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(176 129 176 179), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(182 179 176 179), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(174 169 176 169), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(162 169 90 169), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(96 169 96 129), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(175 227 90 227), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(90 190 90 227), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(52 179 3 179), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(52 228 3 228), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(52 276 3 276), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(155 177 155 169), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(110 191 110 169), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(155 189 155 197), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(350 283 350 329), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(162 197 155 197), -fill => $color, -tags => ['floor2', 'wall']);
    $w->create('line', qw(341 275 341 283), -fill => $color, -tags => ['floor2', 'wall']);

} # end fg2;


sub fg3 {;

    my($w, $color) = @_;

    my($i);
    $i = $w->create('polygon', qw(89 228 89 180 70 180 70 228), -fill => undef, -tags => ['floor3', 'room']);
    $mkFloor::floorLabels{$i} = 316;
    $mkFloor::floorItems{'316'} = $i;
    $w->create('text', qw(79.5 204), -text => '316', -fill => $color, -anchor => 'c', -tags => ['floor3', 'label']);
    $i = $w->create('polygon', qw(115 368 162 368 162 323 115 323), -fill => undef, -tags => ['floor3', 'room']);
    $mkFloor::floorLabels{$i} = 309;
    $mkFloor::floorItems{'309'} = $i;
    $w->create('text', qw(138.5 345.5), -text => '309', -fill => $color, -anchor => 'c', -tags => ['floor3', 'label']);
    $i = $w->create('polygon', qw(164 323 164 368 211 368 211 323), -fill => undef, -tags => ['floor3', 'room']);
    $mkFloor::floorLabels{$i} = 308;
    $mkFloor::floorItems{'308'} = $i;
    $w->create('text', qw(187.5 345.5), -text => '308', -fill => $color, -anchor => 'c', -tags => ['floor3', 'label']);
    $i = $w->create('polygon', qw(256 368 212 368 212 323 256 323), -fill => undef, -tags => ['floor3', 'room']);
    $mkFloor::floorLabels{$i} = 307;
    $mkFloor::floorItems{'307'} = $i;
    $w->create('text', qw(234 345.5), -text => '307', -fill => $color, -anchor => 'c', -tags => ['floor3', 'label']);
    $i = $w->create('polygon', qw(244 276 297 276 297 327 260 327 260 321 244 321), -fill => undef, -tags => ['floor3', 'room']);
    $mkFloor::floorLabels{$i} = 305;
    $mkFloor::floorItems{'305'} = $i;
    $w->create('text', qw(270.5 301.5), -text => '305', -fill => $color, -anchor => 'c', -tags => ['floor3', 'label']);
    $i = $w->create('polygon', qw(251 219 251 203 244 203 244 219), -fill => undef, -tags => ['floor3', 'room']);
    $mkFloor::floorLabels{$i} = '324B';
    $mkFloor::floorItems{'324B'} = $i;
    $w->create('text', qw(247.5 211), -text => '324B', -fill => $color, -anchor => 'c', -tags => ['floor3', 'label']);
    $i = $w->create('polygon', qw(251 249 244 249 244 232 251 232), -fill => undef, -tags => ['floor3', 'room']);
    $mkFloor::floorLabels{$i} = '324A';
    $mkFloor::floorItems{'324A'} = $i;
    $w->create('text', qw(247.5 240.5), -text => '324A', -fill => $color, -anchor => 'c', -tags => ['floor3', 'label']);
    $i = $w->create('polygon', qw(223 135 223 179 177 179 177 135), -fill => undef, -tags => ['floor3', 'room']);
    $mkFloor::floorLabels{$i} = 320;
    $mkFloor::floorItems{'320'} = $i;
    $w->create('text', qw(200 157), -text => '320', -fill => $color, -anchor => 'c', -tags => ['floor3', 'label']);
    $i = $w->create('polygon', qw(114 368 114 323 67 323 67 368), -fill => undef, -tags => ['floor3', 'room']);
    $mkFloor::floorLabels{$i} = 310;
    $mkFloor::floorItems{'310'} = $i;
    $w->create('text', qw(90.5 345.5), -text => '310', -fill => $color, -anchor => 'c', -tags => ['floor3', 'label']);
    $i = $w->create('polygon', qw(23 277 23 321 68 321 68 277), -fill => undef, -tags => ['floor3', 'room']);
    $mkFloor::floorLabels{$i} = 312;
    $mkFloor::floorItems{'312'} = $i;
    $w->create('text', qw(45.5 299), -text => '312', -fill => $color, -anchor => 'c', -tags => ['floor3', 'label']);
    $i = $w->create('polygon', qw(23 229 68 229 68 275 23 275), -fill => undef, -tags => ['floor3', 'room']);
    $mkFloor::floorLabels{$i} = 313;
    $mkFloor::floorItems{'313'} = $i;
    $w->create('text', qw(45.5 252), -text => '313', -fill => $color, -anchor => 'c', -tags => ['floor3', 'label']);
    $i = $w->create('polygon', qw(68 227 23 227 23 180 68 180), -fill => undef, -tags => ['floor3', 'room']);
    $mkFloor::floorLabels{$i} = 314;
    $mkFloor::floorItems{'314'} = $i;
    $w->create('text', qw(45.5 203.5), -text => '314', -fill => $color, -anchor => 'c', -tags => ['floor3', 'label']);
    $i = $w->create('polygon', qw(95 179 95 135 23 135 23 179), -fill => undef, -tags => ['floor3', 'room']);
    $mkFloor::floorLabels{$i} = 315;
    $mkFloor::floorItems{'315'} = $i;
    $w->create('text', qw(59 157), -text => '315', -fill => $color, -anchor => 'c', -tags => ['floor3', 'label']);
    $i = $w->create('polygon', qw(99 226 99 204 91 204 91 226), -fill => undef, -tags => ['floor3', 'room']);
    $mkFloor::floorLabels{$i} = '316B';
    $mkFloor::floorItems{'316B'} = $i;
    $w->create('text', qw(95 215), -text => '316B', -fill => $color, -anchor => 'c', -tags => ['floor3', 'label']);
    $i = $w->create('polygon', qw(91 202 99 202 99 180 91 180), -fill => undef, -tags => ['floor3', 'room']);
    $mkFloor::floorLabels{$i} = '316A';
    $mkFloor::floorItems{'316A'} = $i;
    $w->create('text', qw(95 191), -text => '316A', -fill => $color, -anchor => 'c', -tags => ['floor3', 'label']);
    $i = $w->create('polygon', qw(97 169 109 169 109 192 154 192 154 198 174 198 174 226 101 226 101 179 97 179), -fill => undef, -tags => ['floor3', 'room']);
    $mkFloor::floorLabels{$i} = 319;
    $mkFloor::floorItems{'319'} = $i;
    $w->create('text', qw(141.5 209), -text => '319', -fill => $color, -anchor => 'c', -tags => ['floor3', 'label']);
    $i = $w->create('polygon', qw(65 368 58 368 58 389 1 389 1 333 23 333 23 323 65 323), -fill => undef, -tags => ['floor3', 'room']);
    $mkFloor::floorLabels{$i} = 311;
    $mkFloor::floorItems{'311'} = $i;
    $w->create('text', qw(29.5 361), -text => '311', -fill => $color, -anchor => 'c', -tags => ['floor3', 'label']);
    $i = $w->create('polygon', qw(154 191 111 191 111 169 154 169), -fill => undef, -tags => ['floor3', 'room']);
    $mkFloor::floorLabels{$i} = 318;
    $mkFloor::floorItems{'318'} = $i;
    $w->create('text', qw(132.5 180), -text => '318', -fill => $color, -anchor => 'c', -tags => ['floor3', 'label']);
    $i = $w->create('polygon', qw(175 168 97 168 97 131 175 131), -fill => undef, -tags => ['floor3', 'room']);
    $mkFloor::floorLabels{$i} = 317;
    $mkFloor::floorItems{'317'} = $i;
    $w->create('text', qw(136 149.5), -text => '317', -fill => $color, -anchor => 'c', -tags => ['floor3', 'label']);
    $i = $w->create('polygon', qw(274 194 274 221 306 221 306 194), -fill => undef, -tags => ['floor3', 'room']);
    $mkFloor::floorLabels{$i} = 323;
    $mkFloor::floorItems{'323'} = $i;
    $w->create('text', qw(290 207.5), -text => '323', -fill => $color, -anchor => 'c', -tags => ['floor3', 'label']);
    $i = $w->create('polygon', qw(306 222 274 222 274 249 306 249), -fill => undef, -tags => ['floor3', 'room']);
    $mkFloor::floorLabels{$i} = 325;
    $mkFloor::floorItems{'325'} = $i;
    $w->create('text', qw(290 235.5), -text => '325', -fill => $color, -anchor => 'c', -tags => ['floor3', 'label']);
    $i = $w->create('polygon', qw(263 179 224 179 224 135 263 135), -fill => undef, -tags => ['floor3', 'room']);
    $mkFloor::floorLabels{$i} = 321;
    $mkFloor::floorItems{'321'} = $i;
    $w->create('text', qw(243.5 157), -text => '321', -fill => $color, -anchor => 'c', -tags => ['floor3', 'label']);
    $i = $w->create('polygon', qw(314 169 306 169 306 192 273 192 264 181 264 135 314 135), -fill => undef, -tags => ['floor3', 'room']);
    $mkFloor::floorLabels{$i} = 322;
    $mkFloor::floorItems{'322'} = $i;
    $w->create('text', qw(293.5 163.5), -text => '322', -fill => $color, -anchor => 'c', -tags => ['floor3', 'label']);
    $i = $w->create('polygon', qw(307 240 339 240 339 206 307 206), -fill => undef, -tags => ['floor3', 'room']);
    $mkFloor::floorLabels{$i} = 'Pub Lift3';
    $mkFloor::floorItems{'Pub Lift3'} = $i;
    $w->create('text', qw(323 223), -text => 'Pub Lift3', -fill => $color, -anchor => 'c', -tags => ['floor3', 'label']);
    $i = $w->create('polygon', qw(339 205 307 205 307 171 339 171), -fill => undef, -tags => ['floor3', 'room']);
    $mkFloor::floorLabels{$i} = 'Priv Lift3';
    $mkFloor::floorItems{'Priv Lift3'} = $i;
    $w->create('text', qw(323 188), -text => 'Priv Lift3', -fill => $color, -anchor => 'c', -tags => ['floor3', 'label']);
    $i = $w->create('polygon', qw(350 284 376 284 376 276 397 276 397 309 350 309), -fill => undef, -tags => ['floor3', 'room']);
    $mkFloor::floorLabels{$i} = 303;
    $mkFloor::floorItems{'303'} = $i;
    $w->create('text', qw(373.5 292.5), -text => '303', -fill => $color, -anchor => 'c', -tags => ['floor3', 'label']);
    $i = $w->create('polygon', qw(272 203 272 249 252 249 252 230 244 230 244 221 252 221 252 203), -fill => undef, -tags => ['floor3', 'room']);
    $mkFloor::floorLabels{$i} = 324;
    $mkFloor::floorItems{'324'} = $i;
    $w->create('text', qw(262 226), -text => '324', -fill => $color, -anchor => 'c', -tags => ['floor3', 'label']);
    $i = $w->create('polygon', qw(299 276 299 327 349 327 349 284 341 284 341 276), -fill => undef, -tags => ['floor3', 'room']);
    $mkFloor::floorLabels{$i} = 304;
    $mkFloor::floorItems{'304'} = $i;
    $w->create('text', qw(324 301.5), -text => '304', -fill => $color, -anchor => 'c', -tags => ['floor3', 'label']);
    $i = $w->create('polygon', qw(375 246 375 172 341 172 341 246), -fill => undef, -tags => ['floor3', 'room']);
    $mkFloor::floorLabels{$i} = 301;
    $mkFloor::floorItems{'301'} = $i;
    $w->create('text', qw(358 209), -text => '301', -fill => $color, -anchor => 'c', -tags => ['floor3', 'label']);
    $i = $w->create('polygon', qw(397 246 377 246 377 185 397 185), -fill => undef, -tags => ['floor3', 'room']);
    $mkFloor::floorLabels{$i} = 327;
    $mkFloor::floorItems{'327'} = $i;
    $w->create('text', qw(387 215.5), -text => '327', -fill => $color, -anchor => 'c', -tags => ['floor3', 'label']);
    $i = $w->create('polygon', qw(316 131 316 169 377 169 377 185 397 185 397 131), -fill => undef, -tags => ['floor3', 'room']);
    $mkFloor::floorLabels{$i} = 326;
    $mkFloor::floorItems{'326'} = $i;
    $w->create('text', qw(356.5 150), -text => '326', -fill => $color, -anchor => 'c', -tags => ['floor3', 'label']);
    $i = $w->create('polygon', qw(308 251 242 251 242 274 342 274 342 282 375 282 375 274 397 274 397 248 339 248 339 242 308 242), -fill => undef, -tags => ['floor3', 'room']);
    $mkFloor::floorLabels{$i} = 302;
    $mkFloor::floorItems{'302'} = $i;
    $w->create('text', qw(319.5 261), -text => '302', -fill => $color, -anchor => 'c', -tags => ['floor3', 'label']);
    $i = $w->create('polygon', qw(70 321 242 321 242 200 259 200 259 203 272 203 272 193 263 180 242 180 175 180 175 169 156 169 156 196 177 196 177 228 107 228 70 228 70 275 107 275 107 248 160 248 160 301 107 301 107 275 70 275), -fill => undef, -tags => ['floor3', 'room']);
    $mkFloor::floorLabels{$i} = 306;
    $mkFloor::floorItems{'306'} = $i;
    $w->create('text', qw(200.5 284.5), -text => '306', -fill => $color, -anchor => 'c', -tags => ['floor3', 'label']);
    $w->create('line', qw(341 275 341 283), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(162 197 155 197), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(396 247 399 247), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(399 129 399 311), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(258 202 243 202), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(350 283 350 329), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(251 231 243 231), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(243 220 251 220), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(243 250 243 202), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(155 197 155 190), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(110 192 110 169), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(155 192 110 192), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(155 177 155 169), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(176 197 176 227), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(69 280 69 274), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(21 276 69 276), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(69 262 69 226), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(21 228 69 228), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(21 179 75 179), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(69 179 69 214), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(90 220 90 227), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(90 204 90 202), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(90 203 100 203), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(90 187 90 179), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(90 227 176 227), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(100 179 100 227), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(100 179 87 179), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(96 179 96 129), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(162 169 96 169), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(173 169 176 169), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(182 179 176 179), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(176 129 176 179), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(195 179 226 179), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(224 133 224 179), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(264 179 264 133), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(238 179 264 179), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(273 207 273 193), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(273 235 273 250), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(273 224 273 219), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(273 193 307 193), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(273 222 307 222), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(273 250 307 250), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(384 247 376 247), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(340 206 307 206), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(340 187 340 170), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(340 210 340 201), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(340 247 340 224), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(340 241 307 241), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(376 247 376 170), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(307 250 307 170), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(376 170 307 170), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(315 129 315 170), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(376 283 366 283), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(376 283 376 275), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(399 275 376 275), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(341 275 320 275), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(341 283 350 283), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(298 275 298 329), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(308 275 298 275), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(243 322 243 275), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(243 275 284 275), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(258 322 226 322), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(212 370 212 322), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(214 322 177 322), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(163 370 163 322), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(165 322 129 322), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(84 322 117 322), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(71 322 64 322), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(115 322 115 370), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(66 322 66 370), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(52 322 21 322), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(21 331 0 331), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(21 331 21 133), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(96 133 21 133), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(176 129 96 129), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(315 133 176 133), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(315 129 399 129), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(399 311 350 311), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(350 329 258 329), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(258 322 258 370), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(60 370 258 370), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(60 370 60 391), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(0 391 0 331), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(60 391 0 391), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(307 250 307 242), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(273 250 307 250), -fill => $color, -tags => ['floor3', 'wall']);
    $w->create('line', qw(258 250 243 250), -fill => $color, -tags => ['floor3', 'wall']);

} # end fg3;


# currentRoom is tied to package "mkFloor" for tracing purposes.  All other global variables are also "mkFloor" qualified.


package mkFloor;

sub TIESCALAR {
    $canvas = $_[2];
    bless \($_[1]);
}


sub FETCH {
}


sub STORE {
    &main::roomChanged($canvas);
}


1;
