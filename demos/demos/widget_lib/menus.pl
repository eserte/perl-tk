# menus.pl

sub menus_error;

sub menus {

    # This demonstration script creates a window with a bunch of menus
    # and cascaded menus.

    my ($demo) = @ARG;

    $MENUS->destroy if Exists($MENUS);
    $MENUS = $MW->Toplevel;
    my $w = $MENUS;
    dpos $w;
    $w->title('Menu Demonstration');
    $w->iconname('menus');

    $w_menu = $w->Frame(-relief => 'raised', -borderwidth => 2);
    $w_menu->pack(-fill => 'x');

    my $w_msg = $w->Label(
        -font       => $FONT,
        -wraplength => '4i',
        -justify    => 'left',
        -text       => 'This window contains a collection of menus and cascaded menus.  You can post a menu from the keyboard by typing Alt+x, where "x" is the character underlined on the menu.  You can then traverse among the menus using the arrow keys.  When a menu is posted, you can invoke the current entry by typing space, or you can invoke any entry by typing its underlined character.  If a menu entry has an accelerator, you can invoke the entry without posting the menu just by typing the accelerator.'
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

    my $f = $w_menu->Menubutton(-text => 'File', -underline => 0);
    $f->command(-label => 'Open ...',    -command => [\&menus_error, 'Open']);
    $f->command(-label => 'New',         -command => [\&menus_error, 'New']);
    $f->command(-label  => 'Save',       -command => [\&menus_error, 'Save']);
    $f->command(-label => 'Save As ...', -command => [\&menus_error, 'Save As']);
    $f->separator;
    $f->command(-label => 'Setup ...',   -command => [\&menus_error, 'Setup']);
    $f->command(-label => 'Print ...',   -command => [\&menus_error, 'Print']);
    $f->separator;
    $f->command(-label => 'Quit',        -command => [$w => 'destroy']);

    my $b = $w_menu->Menubutton(-text => 'Basic', -underline => 0);
    $b->command(-label => 'Long entry that does nothing');
    my $label;
    foreach $label (qw(a b c d e f g)) {
	$b->command(
             -label => "Print letter \"$label\"",
             -underline => 14,
	     -accelerator => "Meta+$label",
             -command => [sub {print "$ARG[0]\n"}, $label],
        );
	$b->bind("<Meta-${label}>" => [sub {print "$ARG[0]\n"},$label]);
    }

    $menu_cb = 'Check buttons';
    $menu_rb = 'Radio buttons';
    my $c = $w_menu->Menubutton(-text => 'Cascades', -underline => 0);
    $c->command(
        -label       => 'Print hello', 
        -command     => sub {print "Hello\n"},
	-accelerator => 'Control+a',
        -underline   => 6,
    );
    $w->bind('<Control-a>' => sub {print "Hello\n"});
    $c->command(
        -label       => 'Print goodbye', 
        -command     => sub {print "Goodbye\n"},
	-accelerator => 'Control+b', 
        -underline   => 6,
    );
    $w->bind('<Control-b>' => sub {print "Goodbye\n"});
    $c->cascade(-label => $menu_cb, -underline => 0);
    $c->cascade(-label => $menu_rb, -underline => 0);

    my $cm = $c->cget(-menu); 
    my $cc = $cm->Menu;
    $c->entryconfigure($menu_cb, -menu => $cc);

    $cc->checkbutton(-label => 'Oil checked', -variable => \$oil);
    $cc->checkbutton(-label => 'Transmission checked', -variable => \$trans);
    $cc->checkbutton(-label => 'Brakes checked', -variable => \$brakes);
    $cc->checkbutton(-label => 'Lights checked', -variable => \$lights);
    $cc->separator;
    $cc->command(
        -label => 'See current values',
	-command => [\&seeVars, $MW, qw(oil trans brakes lights)],
    );
    $cc->invoke(1);
    $cc->invoke(3);

    my $rm = $c->cget(-menu); 
    my $rc = $rm->Menu;
    $c->entryconfigure($menu_rb, -menu => $rc);
    my($label);
    foreach $label (qw(10 14 18 24 32)) {
	$rc->radiobutton(
            -label    => "$label point",
            -variable => \$pointSize,
            -value    => $label,
        );
    }
    $rc->separator;
    foreach $label (qw(Roman Bold Italic)) {
	$rc->radiobutton(
            -label    => $label,
            -variable => \$style,
            -value    => $label,
        );
    }
    $rc->separator;
    $rc->command(
        -label => 'See current values',
	-command => [\&seeVars, $MW, qw(pointSize style)],
    );
    $rc->invoke(1);
    $rc->invoke(7);

    my $i = $w_menu->Menubutton(-text => 'Icons', -underline => 0);
    $i->command(
        -bitmap => '@'.Tk->findINC('demos/images/pattern'),
	-command => [$DIALOG_ICON => 'show'],
    );
    foreach $label (qw(info questhead error)) {
	$i->command(
            -bitmap  => $label,
            -command => [sub {print "You invoked the $ARG[0] bitmap\n"},$label]
        );
    }

    my $m = $w_menu->Menubutton(-text => 'More', -underline => 0);
    foreach $label ('An entry', 'Another entry', 'Does nothing',
		    'Does almost nothing', 'Make life meaningful') {
	$m->command( 
            -label   => $label, 
	    -command => [sub {print "You invoked \"$ARG[0]\"\n"},$label]
        );
    }

    my $k = $w_menu->Menubutton(-text => 'Colors', -underline => 1);
    foreach $label (qw(red orange yellow green blue)) {
	$k->command(
            -label      => $label,
            -background => $label,
	    -command => [sub {print "You invoked \"$ARG[0]\"\n"},$label]
        );
    }
    
    $f->pack(-side=>'left');
    $b->pack(-side=>'left');
    $c->pack(-side=>'left');
    $i->pack(-side=>'left');
    $m->pack(-side=>'left');
    $k->pack(-side=>'left');

} # end menus

sub menus_error {

    # Generate a background error, which may even be displayed in a window if
    # using ErrorDialog.  (Swiped from Carp.)

    my($msg) = @ARG;

    $msg = "This is just a demo: no action has been defined for \"$msg\".";
    my $error = '';
    my @mess = '';
    my $i = 0;
    my ($pack,$file,$line,$sub);
    while (($pack,$file,$line,$sub) = caller($i++)) {
        push @mess, "\t$sub " if $error eq "called";
        push @mess, "$error at $file line $line";
        $error = "called";
    }
    Tk::BackgroundError($MW, $msg, @mess);

} # end menus_error

1;
