# menus2.pl

use subs qw/menus_error2/;
use vars qw/$TOP/;

sub menus2 {

    # This demonstration script creates a window with a bunch of menus
    # and cascaded menus, but uses -menuitems rather than the Tcl/Tk way.

    my ($demo) = @_;
    $TOP = $MW->WidgetDemo(
        -name     => $demo,
        -text     => '',				      
        -title    => 'Menuitems Demonstration',
        -iconname => 'menus2',
    );

    my $menubar = $TOP->Frame(-relief => 'raised', -borderwidth => 2);
    $menubar->grid(qw/-sticky ew/);
    my $f = $menubar->Menubutton(qw/-text File -underline 0 -menuitems/ =>
        [
         [Button => 'Open ...',    -command => [\&menus_error2, 'Open']],
	 [Button => 'New',         -command => [\&menus_error2, 'New']],
	 [Button => 'Save',        -command => [\&menus_error2, 'Save']],
	 [Button => 'Save As ...', -command => [\&menus_error2, 'Save As']],
	 [Separator => ''],
	 [Button => 'Setup ...',   -command => [\&menus_error2, 'Setup']],
	 [Button => 'Print ...',   -command => [\&menus_error2, 'Print']],
	 [Separator => ''],
	 [Button => 'Quit',        -command => [$TOP => 'bell']],
	])->grid(qw/-row 0 -column 0 -sticky w/);

    my $b = $menubar->Menubutton(qw/-text Basic -underline 0 -menuitems/ =>
        [
	 [Button => 'Long entry that does nothing'],
	  map (
	       [Button       => "Print letter \"~$_\"",
	        -command     => [sub {print "$_[0]\n"}, $_],
	        -accelerator => "Meta+$_" ],
	       ('a' .. 'g')
	  ), 
	])->grid(qw/-row 0 -column 1 -sticky w/);

    my $menu_cb = '~Check buttons';
    my $menu_rb = '~Radio buttons';
    my $c = $menubar->Menubutton(qw/-text Cascades -underline 0 -menuitems/ =>
        [        
	 [Button => 'Print ~hello',   -command => sub {print "Hello\n"},
	  -accelerator => 'Control+a'],
	 [Button => 'Print ~goodbye', -command => sub {print "Goodbye\n"},
	  -accelerator => 'Control+b'],
	 [Cascade => $menu_cb, -menuitems =>
	  [
	   [Checkbutton => 'Oil checked',          -variable => \$OIL],
	   [Checkbutton => 'Transmission checked', -variable => \$TRANS],
	   [Checkbutton => 'Brakes checked',       -variable => \$BRAKES],
	   [Checkbutton => 'Lights checked',       -variable => \$LIGHTS],
	   [Separator => ''],
	   [Button => 'See current values', -command => 
	    [\&see_vars, $TOP, [
				['oil',     \$OIL],
				['trans',   \$TRANS],
				['brakes',  \$BRAKES],
				['lights',  \$LIGHTS],
				],
            ], # end see_vars
	   ], # end button
	  ], # end checkbutton menuitems
	 ], # end checkbuttons cascade
	 [Cascade => $menu_rb, -menuitems =>
	  [
	   map (
		[Radiobutton => "$_ point", -variable => \$POINT_SIZE,
		 -value => $_,
		 ],
		(qw/10 14 18 24 32/),
		),
	   [Separator => ''],
	   map (
		[Radiobutton => "$_", -variable => \$FONT_STYLE,
		 -value => $_,
		 ],
		(qw/Roman Bold Italic/),
		),
	   [Separator => ''],
	   [Button => 'See current values', -command =>
	    [\&see_vars, $TOP, [
				['point size', \$POINT_SIZE],
				['font style', \$FONT_STYLE],
				],
	     ], # end see_vars
	    ], # end button
	   ], # end radiobutton menuitems
	  ], # end radiobuttons cascade
         ])->grid(qw/-row 0 -column 2 -sticky w/);

    $TOP->bind('<Control-a>' => sub {print "Hello\n"});
    $TOP->bind('<Control-b>' => sub {print "Goodbye\n"});

    # Fetch the Cascades menu, and from that get the checkbutton and
    # radiobutton cascade menus and invoke a few menu items.

    my $cm = $c->cget(-menu);
    $menu_cb = substr $menu_cb, 1;
    my $cc = $cm->entrycget($menu_cb, -menu);
    $cc->invoke(1);
    $cc->invoke(3);
    $menu_rb = substr $menu_rb, 1;
    my $cr = $cm->entrycget($menu_rb, -menu);
    $cr->invoke(1);
    $cr->invoke(7);

    my $i = $menubar->Menubutton(qw/-text Icons -underline 0 -menuitems/ =>
        [
	 [Button   => '', -bitmap => '@'.Tk->findINC('demos/images/pattern'),
	  -command => [$DIALOG_ICON => 'Show']],
	 map (
	      [Button  => '', -bitmap => $_,
	      -command => 
	       [sub {print "You invoked the \"$_[0]\" bitmap\n"}, $_]],
	      (qw/info questhead error/),
	      ),
	 ])->grid(qw/-row 0 -column 3 -sticky w/);

    my $m = $menubar->Menubutton(qw/-text More -underline 0 -menuitems/ =>
        [
	 map (
	      [Button   => $_,
	       -command => 
	       [sub {print "You invoked \"$_[0]\"\n"}, $_]],
	      ('An entry', 'Another entry', 'Does nothing',
	       'Does almost nothing', 'Make life meaningful'),
	      ),
	 ])->grid(qw/-row 0 -column 4 -sticky w/);

    my $k = $menubar->Menubutton(qw/-text Colors -underline 1 -menuitems/ =>
        [
	 map (
	      [Button      => $_,
	       -background => $_,
	       -command    => 
	       [sub {print "You invoked \"$_[0]\"\n"}, $_]],
	      (qw/red orange yellow green blue/),
	      ),
	 ])->grid(qw/-row 0 -column 5 -sticky w/);

    my $details = $TOP->Label(qw/-wraplength 4i -justify left -text/ => 'This window contains a collection of menus and cascaded menus.  You can post a menu from the keyboard by typing Alt+x, where "x" is the character underlined on the menu.  You can then traverse among the menus using the arrow keys.  When a menu is posted, you can invoke the current entry by typing space, or you can invoke any entry by typing its underlined character.  If a menu entry has an accelerator, you can invoke the entry without posting the menu just by typing the accelerator.', -font => $FONT)->grid;

} # end menus

sub menus_error2 {


    # Generate a background error, which may even be displayed in a window if
    # using ErrorDialog. 

    my($msg) = @_;

    $msg = "This is just a demo: no action has been defined for \"$msg\".";
    $TOP->BackTrace($msg);

} # end menus_error


1;
