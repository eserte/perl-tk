# menus.pl

use subs qw/menus_error/;
use vars qw/$TOP/;

sub menus {

    # This demonstration script creates a window with a bunch of menus
    # and cascaded menus.

    my ($demo) = @_;
    $TOP = $MW->WidgetDemo(
        -name     => $demo,
	-text     => '',
        -title    => 'Menu Demonstration',
        -iconname => 'menus',
    );

    my $menu = $TOP->Frame(-relief => 'raised', -borderwidth => 2);
    $menu->pack(-fill => 'x');
    my $f = $menu->Menubutton(-text => 'File', -underline => 0);
    $f->command(-label => 'Open ...',    -command => [\&menus_error, 'Open']);
    $f->command(-label => 'New',         -command => [\&menus_error, 'New']);
    $f->command(-label  => 'Save',       -command => [\&menus_error, 'Save']);
    $f->command(-label => 'Save As ...', -command => [\&menus_error, 'Save As']);
    $f->separator;
    $f->command(-label => 'Setup ...',   -command => [\&menus_error, 'Setup']);
    $f->command(-label => 'Print ...',   -command => [\&menus_error, 'Print']);
    $f->separator;
    $f->command(-label => 'Quit',        -command => [$TOP => 'bell']);

    my $b = $menu->Menubutton(-text => 'Basic', -underline => 0);
    $b->command(-label => 'Long entry that does nothing');
    my $label;
    foreach $label (qw(a b c d e f g)) {
	$b->command(
             -label => "Print letter \"$label\"",
             -underline => 14,
	     -accelerator => "Meta+$label",
             -command => sub {print "$label\n"},
        );
	$b->bind("<Meta-${label}>" => sub {print "$label\n"});
    }

    my $menu_cb = 'Check buttons';
    my $menu_rb = 'Radio buttons';
    my $c = $menu->Menubutton(-text => 'Cascades', -underline => 0);
    $c->command(
        -label       => 'Print hello', 
        -command     => sub {print "Hello\n"},
	-accelerator => 'Control+a',
        -underline   => 6,
    );
    $TOP->bind('<Control-a>' => sub {print "Hello\n"});
    $c->command(
        -label       => 'Print goodbye', 
        -command     => sub {print "Goodbye\n"},
	-accelerator => 'Control+b', 
        -underline   => 6,
    );
    $TOP->bind('<Control-b>' => sub {print "Goodbye\n"});
    $c->cascade(-label => $menu_cb, -underline => 0);
    $c->cascade(-label => $menu_rb, -underline => 0);

    my $cm = $c->cget(-menu); 
    my $cc = $cm->Menu;
    $c->entryconfigure($menu_cb, -menu => $cc);

    $cc->checkbutton(-label => 'Oil checked', -variable => \$OIL);
    $cc->checkbutton(-label => 'Transmission checked', -variable => \$TRANS);
    $cc->checkbutton(-label => 'Brakes checked', -variable => \$BRAKES);
    $cc->checkbutton(-label => 'Lights checked', -variable => \$LIGHTS);
    $cc->separator;
    $cc->command(
        -label => 'See current values',
	-command => [\&see_vars, $MW, [
                                       ['oil',     \$OIL],
                                       ['trans',   \$TRANS],
                                       ['brakes',  \$BRAKES],
                                       ['lights',  \$LIGHTS],
                                      ],
                    ],
    );
    $cc->invoke(1);
    $cc->invoke(3);

    my $rm = $c->cget(-menu); 
    my $rc = $rm->Menu;
    $c->entryconfigure($menu_rb, -menu => $rc);

    foreach $label (qw(10 14 18 24 32)) {
	$rc->radiobutton(
            -label    => "$label point",
            -variable => \$POINT_SIZE,
            -value    => $label,
        );
    }
    $rc->separator;
    foreach $label (qw(Roman Bold Italic)) {
	$rc->radiobutton(
            -label    => $label,
            -variable => \$FONT_STYLE,
            -value    => $label,
        );
    }
    $rc->separator;
    $rc->command(
        -label => 'See current values',
	-command => [\&see_vars, $MW, [
                                      ['point size', \$POINT_SIZE],
                                      ['font style', \$FONT_STYLE],
                                     ],
                    ],
    );
    $rc->invoke(1);
    $rc->invoke(7);

    my $i = $menu->Menubutton(-text => 'Icons', -underline => 0);
    $i->command(
        -bitmap => '@'.Tk->findINC('demos/images/pattern'),
	-command => [$DIALOG_ICON => 'Show'],
    );
    foreach $label (qw(info questhead error)) {
	$i->command(
            -bitmap  => $label,
            -command => sub {print "You invoked the \"$label\" bitmap\n"},
        );
    }

    my $m = $menu->Menubutton(-text => 'More', -underline => 0);
    foreach $label ('An entry', 'Another entry', 'Does nothing',
		    'Does almost nothing', 'Make life meaningful') {
	$m->command( 
            -label   => $label, 
	    -command => sub {print "You invoked \"$label\"\n"},
        );
    }

    my $k = $menu->Menubutton(-text => 'Colors', -underline => 1);
    foreach $label (qw(red orange yellow green blue)) {
	$k->command(
            -label      => $label,
            -background => $label,
	    -command => sub {print "You invoked \"$label\"\n"},
        );
    }
    
    my (@pl) = qw/-side left/;
    $f->pack(@pl);
    $b->pack(@pl);
    $c->pack(@pl);
    $i->pack(@pl);
    $m->pack(@pl);
    $k->pack(@pl);

    my $details = $TOP->Label(qw/-wraplength 4i -justify left -text/ => 'This window contains a collection of menus and cascaded menus.  You can post a menu from the keyboard by typing Alt+x, where "x" is the character underlined on the menu.  You can then traverse among the menus using the arrow keys.  When a menu is posted, you can invoke the current entry by typing space, or you can invoke any entry by typing its underlined character.  If a menu entry has an accelerator, you can invoke the entry without posting the menu just by typing the accelerator.', -font => $FONT)->pack;

} # end menus

sub menus_error {


    # Generate a background error, which may even be displayed in a window if
    # using ErrorDialog. 

    my($msg) = @_;

    $msg = "This is just a demo: no action has been defined for \"$msg\".";
    $TOP->BackTrace($msg);

} # end menus_error


1;
