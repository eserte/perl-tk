# twind.pl

sub textWindOn;
sub textWindOff;
sub textWindPlot;
sub textWindDel;
sub embPlotDown;
sub embPlotMove;
sub embDefBg;

sub twind {

    # Create a top-level window with a text widget that demonstrates the
    # use of embedded windows in texts.

    my($demo) = @ARG;

    $TWIND->destroy if Exists($TWIND);
    $TWIND = $mw->Toplevel;
    my $w = $TWIND;
    dpos $w;
    $w->title('Text Demonstration - Embedded Windows');
    $w->iconname('twind');

    $twind::w_buttons = $w->Frame;
    $twind::w_buttons->pack(qw( -side bottom -expand y -fill x -pady 2m));
    my $w_dismiss = $twind::w_buttons->Button(
        -text    => 'Dismiss',
        -command => ['destroy', $w],
    );
    $w_dismiss->pack(qw(-side left -expand 1));
    my $w_see = $twind::w_buttons->Button(
        -text    => 'See Code',
        -command => [\&seeCode, $demo],
    );
    $w_see->pack(qw(-side left -expand 1));

    my $w_f = $w->Frame(-highlightthickness => 2, -borderwidth => 2,
			-relief => 'sunken');
    $twind::w_t = $w_f->Text(-font => $FONT, -setgrid => 'true',
				  -width => 70, -height => 35, -wrap => 'word',
				  -highlightthickness => 0, -bd => 0);
    $twind::w_t->pack(-expand => 'yes', -fill => 'both');
    my $w_s = $w->Scrollbar(-command => ['yview', $twind::w_t]);
    $w_s->pack(-side => 'right', -fill => 'y');
    $w_f->pack(-expand => 'yes', -fill => 'both');

    $twind::w_t->configure(-yscrollcommand => ['set', $w_s]);
    $twind::w_t->tag('configure', 'center', -justify => 'center',
			  -spacing1 => '5m', -spacing3 => '5m');
    $twind::w_t->tag('configure', 'buttons', -lmargin1 => '1c',
			  -lmargin2 =>'1c', -rmargin => '1c',
			  -spacing1 => '3m', -spacing2 => 0, -spacing3 => 0);

    my $w_t_on = $twind::w_t->Button(-text => 'Turn On',
					  -command => \&textWindOn,
					  -cursor => 'top_left_arrow');
    my $w_t_off = $twind::w_t->Button(-text => 'Turn Off',
					   -command => \&textWindOff,
					   -cursor => 'top_left_arrow');
    my $w_t_click = $twind::w_t->Button(-text => 'Click Here',
					     -command => \&textWindPlot,
					     -cursor => 'top_left_arrow');
    my $w_t_delete = $twind::w_t->Button(-text => 'Delete',
					      -command => \&textWindDel,
					      -cursor => 'top_left_arrow');

    $twind::w_t->insert('end', "A text widget can contain other widgets embedded ");
    $twind::w_t->insert('end', "it.  These are called ");
    $twind::w_t->insert('end', "embedded windows");
    $twind::w_t->insert('end', ", and they can consist of arbitrary widgets.  ");
    $twind::w_t->insert('end', "For example, here are two embedded button ");
    $twind::w_t->insert('end', "widgets.  You can click on the first button to ");
    $twind::w_t->window('create', 'end', -window => $w_t_on);
    $twind::w_t->insert('end', " horizontal scrolling, which also turns off ");
    $twind::w_t->insert('end', "word wrapping.  Or, you can click on the second ");
    $twind::w_t->insert('end', "button to\n");
    $twind::w_t->window('create', 'end', -window => $w_t_off);
    $twind::w_t->insert('end', " horizontal scrolling and turn back on word wrapping.\n\n");

    $twind::w_t->insert('end', "Or, here is another example.  If you ");
    $twind::w_t->window('create', 'end', -window => $w_t_click);
    $twind::w_t->insert('end', " a canvas displaying an x-y plot will appear right here.");
    $twind::w_t->mark('set', 'plot', 'insert');
    $twind::w_t->mark('gravity', 'plot', 'left');
    $twind::w_t->insert('end', "  You can drag the data points around with the mouse, ");
    $twind::w_t->insert('end', "or you can click here to ");
    $twind::w_t->window('create', 'end', -window => $w_t_delete);
    $twind::w_t->insert('end', " the plot again.\n\n");

    $twind::w_t->insert('end', "You may also find it useful to put embedded windows in ");
    $twind::w_t->insert('end', "a text without any actual text.  In this case the ");
    $twind::w_t->insert('end', "text widget acts like a geometry manager.  For ");
    $twind::w_t->insert('end', "example, here is a collection of buttons laid out ");
    $twind::w_t->insert('end', "neatly into rows by the text widget.  These buttons ");
    $twind::w_t->insert('end', "can be used to change the background color of the ");
    $twind::w_t->insert('end', "text widget (\"Default\" restores the color to ");
    $twind::w_t->insert('end', "its default).  If you click on the button labeled ");
    $twind::w_t->insert('end', "\"Short\", it changes to a longer string so that ");
    $twind::w_t->insert('end', "you can see how the text widget automatically ");
    $twind::w_t->insert('end', "changes the layout.  Click on the button again ");
    $twind::w_t->insert('end', "to restore the short string.\n");

    my $w_t_default = $twind::w_t->Button(
        -text => 'Default',
	-command => [\&embDefBg, $twind::w_t],
	-cursor  => 'top_left_arrow',
    );
    $twind::w_t->window('create', 'end', -window => $w_t_default,
			     -padx => 3);
    $embToggle = 'Short';
    my $w_t_toggle = $twind::w_t->Checkbutton(
        -textvariable => \$embToggle,
        -indicatoron  => 0, 
        -variable     => \$embToggle,
        -onvalue      => 'A much longer string',
        -offvalue     => 'Short',
         -cursor      => 'top_left_arrow',
    );
    $twind::w_t->window('create', 'end', -window => $w_t_toggle,
			     -padx => 3, -pady => 2);
    my($i, $color) = (1, '');
    foreach $color (qw(AntiqueWhite3 Bisque1 Bisque2 Bisque3 Bisque4
		       SlateBlue3 RoyalBlue1 SteelBlue2 DeepSkyBlue3
		       LightBlue1 DarkSlateGray1 Aquamarine2 DarkSeaGreen2
		       SeaGreen1 Yellow1 IndianRed1 IndianRed2 Tan1 Tan4)) {
	my $color_name = "w_t_color${i}";
	${$color_name} = $twind::w_t->Button(-text => "$color",
						  -cursor => 'top_left_arrow');
        ${$color_name}->configure(-command => [sub {
	    shift->configure(@ARG);
	}, $twind::w_t, -background => $color]);
        $twind::w_t->window('create', 'end', -window => ${$color_name},
                                 -padx => 3, -pady => 2);
        $i++;
    }
    $twind::w_t->tag('add', 'buttons', $w_t_default, 'end');

} # end twind

sub textWindOn {

    $twind::w_s2->destroy if Exists($twind::w_s2);
    $twind::w_s2 = $TWIND->Scrollbar(
        -orient => 'horizontal',
	-command => ['xview', $twind::w_t],
    );
    $twind::w_s2->pack('-after' => $twind::w_buttons,
			    -side => 'bottom', -fill => 'x');
    $twind::w_t->configure(-xscrollcommand => 
				['set', $twind::w_s2], -wrap => 'none');

} # end textWindOn

sub textWindOff {

    $twind::w_s2->destroy if Exists($twind::w_s2);
    $twind::w_t->configure(-xscrollcommand => undef, -wrap => 'word');

} # end textWindOff

sub textWindPlot {

    return if Exists($twind::c);
    $twind::c = $twind::w_t->Canvas(-relief => 'sunken', 
					     -width => '450', -height => '300',
					     -cursor => 'top_left_arrow');

    my $font = '-*-Helvetica-Medium-R-Normal--*-180-*-*-*-*-*-*';

    $twind::c->create('line', qw(100 250 400 250 -width 2));
    $twind::c->create('line', qw(100 250 100 50 -width 2));
    $twind::c->create('text', 225, 20, -text => 'A Simple Plot',
			  -fill => 'brown', -font => $font);
	
    my($i, $x, $y, $point, $item);
    for ($i = 0; $i <= 10; $i++) {
	$x  = 100 + ($i*30);
	$twind::c->create('line', $x, 250, $x, 245, -width => 2);
	$twind::c->create('text', $x, 254, -text => 10*$i, 
			      -anchor => 'n', -font => $font);
    }
    for ($i = 0; $i <= 5; $i++) {
	$y  = 250 - ($i*40);
	$twind::c->create('line', 100, $y, 105, $y, -width => 2);
	$twind::c->create('text', 96, $y, -text => $i*50.0, -anchor => 'e',
			      -font => $font);
    }
    
    foreach $point ([12, 56], [20, 94], [33, 98], [32, 120], [61, 180],
		    [75, 160], [98, 223]) {
	$x = 100 + (3 * $point->[0]);
	$y = 250 - (4 * $point->[1]) / 5;
	$item  = $twind::c->create('oval', $x-6, $y-6, $x+6, $y+6,
	    qw(-width 1 -outline black -fill SkyBlue2));
	$twind::c->addtag('point', 'withtag', $item);
    }

    $twind::c->bind('point', '<Any-Enter>' => [sub {
	shift->itemconfigure(@ARG);
    }, qw(current -fill red)]);
    $twind::c->bind('point', '<Any-Leave>' => [sub {
	shift->itemconfigure(@ARG);
    }, qw(current -fill SkyBlue2)]);
    $twind::c->bind('point', '<1>' => sub {
	my($c, $e) = @ARG;
        my $e = $c->XEvent;
	embPlotDown($c, $e->x, $e->y);
    });
    $twind::c->bind('point', '<ButtonRelease-1>' => sub {
        shift->dtag('selected');
    });
    $twind::c->Tk::bind('<B1-Motion>' => sub {
	my($c, $e) = @ARG;
        my $e = $c->XEvent;
	embPlotMove($c, $e->x, $e->y);
    });
    
    while ($twind::w_t->get('plot') =~ / |\t|\n/) {
	$twind::w_t->delete('plot');
    }
    $twind::w_t->insert('plot', "\n");
    $twind::w_t->window('create', 'plot', -window => $twind::c);
    $twind::w_t->tag('add', 'center', 'plot');
    $twind::w_t->insert('plot', "\n");

} # end textWindPlot

sub textWindDel {

    if (Exists($twind::c)) {
	$twind::w_t->delete($twind::c);
	while ($twind::w_t->get('plot') =~ / |\t|\n/) {
	    $twind::w_t->delete('plot');
	}
	$twind::w_t->insert('plot', '  ');
    }

} # end textWindDel

$twind::embPlot{'lastX'} = 0;
$twind::embPlot{'lastY'} = 0;

sub embPlotDown {
    
    my($w, $x, $y) = @ARG;

    $w->dtag('selected');
    $w->addtag('selected', 'withtag', 'current');
    $w->raise('current');
    $twind::embPlot{'lastX'} = $x;
    $twind::embPlot{'lastY'} = $y;

} # end embPlotDown

sub embPlotMove {

    my($w, $x, $y) = @ARG;

    $w->move('selected', $x - $twind::embPlot{'lastX'},
	     $y - $twind::embPlot{'lastY'});
    $twind::embPlot{'lastX'} = $x;
    $twind::embPlot{'lastY'} = $y;

} # end embPlotMove

sub embDefBg {

    my($t) = @ARG;

    $t->configure(-background => ($t->configure(-background))[3]);

} # end embDefBg

1;
