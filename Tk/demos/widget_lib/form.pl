# form.pl

sub form {

    # Create a top-level window that displays a bunch of entries with 
    # tabs set up to move between them.

    my($demo) = @ARG;

    $FORM->destroy if Exists($FORM);
    $FORM = $mw->Toplevel;
    my $w = $FORM;
    dpos $w;
    $w->title('Form Demonstration');
    $w->iconname('form');

    my $w_msg = $w->Label(
        -font       => $FONT,
        -wraplength => '4i',
        -justify    => 'left',
        -text       => 'This window contains a simple form where you can type in the various entries and use tabs to move circularly between the entries.',
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

    foreach ('Name:', 'Address:', '', '', 'Phone:') {
	my $f = $w->Frame(-bd => 2);
	my $e = $f->Entry(-relief => 'sunken', -width => 40);
	my $l = $f->Label(-text => $ARG);
	$f->pack(-side => 'top', -fill => 'x');
	$e->pack(-side => 'right');
	$l->pack(-side => 'left');
	$e->focus if $ARG eq 'Name:';
    }
    $w->bind('<Return>', ['destroy', $w]);

} # end form

1;
