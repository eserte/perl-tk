# menbut.pl

use vars qw/$TOP/;

sub menbut {
    my($demo) = @_;
    $TOP = $MW->WidgetDemo(
        -name             => $demo,
        -text             => '',
        -title            => 'Menubutton Demo',
        -iconname         => 'Menubutton',
    );

    my @menubuttons;
    foreach (qw/below right left above/) {
	my $pos = ucfirst;
	my $menubutton = $TOP->Menubutton(qw/-underline 0 -relief raised/,
					  -text => $pos, -direction => $_);
	push @menubuttons, $menubutton;
	my $menu = $menubutton->menu(qw/-tearoff 0/);
	$menubutton->configure(-menu => $menu);
	$menubutton->command(-label => "$pos menu: first item", -command =>
        sub {print "You selected the first item from the $pos menu.\n"});
        $menubutton->command(-label => "$pos menu: second item", -command =>
           sub {print "You selected the second item from the $pos menu.\n"});
    }
    $menubuttons[0]->grid(qw/-row 0 -column 1 -sticky n/);
    $menubuttons[3]->grid(qw/-row 2 -column 1 -sticky n/);
    $menubuttons[1]->grid(qw/-row 1 -column 0 -sticky w/);
    $menubuttons[2]->grid(qw/-row 1 -column 2 -sticky e/);

    my $body = $TOP->Frame;
    $body->grid(qw/-row 1 -column 1 -sticky news/);
    $body->Label(qw/-wraplength 300 -justify left/, -font => 'Helvetica 14',
	        -text => 'This is a demonstration of menubuttons. The "Below" menubutton pops its menu below the button; the "Right" button pops to the right, etc. There are two option menus directly below this text; one is just a standard menu and the other is a 16-color palette.')->pack(qw/-side top -padx 25
						        -pady 25/);
    $bbutt = $body->Frame->pack(qw/-padx 25 -pady 25/);
    $bbutt->Optionmenu(-options => [qw/one two three/])->pack(qw/-side left 
						        -padx 25 -pady 25/);

    my $colors = $bbutt->Menubutton(qw/-text Colors -relief raised/)->
        pack(qw/-side left -padx 25 -pady 25/);
    my $m = $colors->Menu(-tearoff => 1);
    my(@colors) = qw/Black red4 DarkGreen  NavyBlue gray75 Red Green Blue
        gray50 Yellow Cyan Magenta White Brown  DarkSeaGreen  DarkViolet/;
    foreach (@colors) {
	$m->command(-label => $_);
    }
    $colors->configure(-menu => $m);

    my $topBorderColor = 'gray50';
    my $bottomBorderColor = 'gray75';

    for (my $i = 1; $i <= $#colors + 1; $i++) {
        my $name = $m->entrycget($i, -label);
        my $i1 = $m->Photo(qw/-height 16 -width 16/);
        $i1->put($topBorderColor, qw/-to 0 0 16 1/);
        $i1->put($topBorderColor, qw/-to 0 1 1 16/);
        $i1->put($bottomBorderColor, qw/-to 0 15 16 16/);
        $i1->put($bottompBorderColor, qw/-to 15 1 16 15/);
        $i1->put($name, qw/-to 1 1 15 15/);
 
        # Incomplete demo.... Tk Optionmenu has no -selectionimage, so I'm
        # faking it with a mere menu.
   
#        $i2 = $m->Photo(qw/-height 16 -width 16/);
#        $i2->put(qw/Black -to 0 0 16 2/);
#        $i2->put(qw/Black -to 0 2 2 16/);
#        $i2->put(qw/Black -to 2 14 16 16/);
#        $i2->put(qw/Black -to 14 2 16 14/);
#        $i2->put($name, qw/-to 2 2 14 14/);
        $m->entryconfigure($i, -image => $i1);
    }

    foreach my $i (qw/Black gray75 gray50 White/) {
        $m->entryconfigure($i, qw/-columnbreak 1/);
    }

} # end menbut

1;
