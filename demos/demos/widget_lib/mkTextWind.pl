

sub textWindOn {

    $mkTextWind::w_s2->destroy if Exists($mkTextWind::w_s2);
    $mkTextWind::w_s2 = $mkTextWind->Scrollbar(-orient => 'horizontal', -command => ['xview', $mkTextWind::w_t]);
    $mkTextWind::w_s2->pack('-after' => $mkTextWind_ok, -side => 'bottom', -fill => 'x');
    $mkTextWind::w_t->configure(-xscrollcommand => ['set', $mkTextWind::w_s2], -wrap => 'none');

} # end textWindOn


sub textWindOff {

    $mkTextWind::w_s2->destroy if Exists($mkTextWind::w_s2);
    $mkTextWind::w_t->configure(-xscrollcommand => undef, -wrap => 'word');

} # end textWindOff


sub textWindPlot {

    return if Exists($mkTextWind_c);
    $mkTextWind_c = $mkTextWind::w_t->Canvas(-relief => 'sunken', -width => '450', -height => '300',
				-cursor => 'top_left_arrow');

    $font = '-Adobe-Helvetica-Medium-R-Normal--*-180-*-*-*-*-*-*';

    $mkTextWind_c->create('line', qw(100 250 400 250 -width 2));
    $mkTextWind_c->create('line', qw(100 250 100 50 -width 2));
    $mkTextWind_c->create('text', 225, 20, -text => 'A Simple Plot', -fill => 'brown', -font => $font);

    my($i, $x, $y, $point, $item);
    for ($i = 0; $i <= 10; $i++) {
	$x  = 100 + ($i*30);
	$mkTextWind_c->create('line', $x, 250, $x, 245, -width => 2);
	$mkTextWind_c->create('text', $x, 254, -text => 10*$i, -anchor => 'n', -font => $font);
    }
    for ($i = 0; $i <= 5; $i++) {
	$y  = 250 - ($i*40);
	$mkTextWind_c->create('line', 100, $y, 105, $y, -width => 2);
	$mkTextWind_c->create('text', 96, $y, -text => $i*50.0, -anchor => 'e', -font => $font);
    }

    foreach $point ([12, 56], [20, 94], [33, 98], [32, 120], [61, 180], [75, 160], [98, 223]) {
	$x = 100 + (3 * $point->[0]);
	$y = 250 - (4 * $point->[1]) / 5;
	$item  = $mkTextWind_c->create('oval', $x-6, $y-6, $x+6, $y+6, qw(-width 1 -outline black -fill SkyBlue2));
	$mkTextWind_c->addtag('point', 'withtag', $item);
    }

    $mkTextWind_c->bind('point', '<Any-Enter>' => [sub {
	shift->itemconfigure(@_);
    }, qw(current -fill red)]);
    $mkTextWind_c->bind('point', '<Any-Leave>' => [sub {
	shift->itemconfigure(@_);
    }, qw(current -fill SkyBlue2)]);
    $mkTextWind_c->bind('point', '<1>' => sub {
	my($c, $e) = @_;
        my $e = $c->XEvent;
	embPlotDown($c, $e->x, $e->y);
    });
    $mkTextWind_c->bind('point', '<ButtonRelease-1>' => sub {
        shift->dtag('selected');
    });
    $mkTextWind_c->Tk::bind('<B1-Motion>' => sub {
	my($c, $e) = @_;
        my $e = $c->XEvent;
	embPlotMove($c, $e->x, $e->y);
    });

    while ($mkTextWind::w_t->get('plot') =~ / |\t|\n/) {
	$mkTextWind::w_t->delete('plot');
    }
    $mkTextWind::w_t->insert('plot', "\n");
    $mkTextWind::w_t->window('create', 'plot', -window => $mkTextWind_c);
    $mkTextWind::w_t->tag('add', 'center', 'plot');
    $mkTextWind::w_t->insert('plot', "\n");

} # end textWindPlot


sub textWindDel {

    if (Exists($mkTextWind_c)) {
	$mkTextWind::w_t->delete($mkTextWind_c);
	while ($mkTextWind::w_t->get('plot') =~ / |\t|\n/) {
	    $mkTextWind::w_t->delete('plot');
	}
	$mkTextWind::w_t->insert('plot', '  ');
    }

} # end textWindDel


$mkTextWind::embPlot{'lastX'} = 0;
$mkTextWind::embPlot{'lastY'} = 0;


sub embPlotDown {

    my($w, $x, $y) = @_;

    $w->dtag('selected');
    $w->addtag('selected', 'withtag', 'current');
    $w->raise('current');
    $mkTextWind::embPlot{'lastX'} = $x;
    $mkTextWind::embPlot{'lastY'} = $y;

} # end embPlotDown


sub embPlotMove {

    my($w, $x, $y) = @_;

    $w->move('selected', $x - $mkTextWind::embPlot{'lastX'}, $y - $mkTextWind::embPlot{'lastY'});
    $mkTextWind::embPlot{'lastX'} = $x;
    $mkTextWind::embPlot{'lastY'} = $y;

} # end embPlotMove


sub embDefBg {

    my($t) = @_;

    $t->configure(-background => ($t->configure(-background))[3]);

} # end embDefBg

sub mkTextWind {

    # Create a top-level window with a text widget that demonstrates the use of embedded windows in texts.

    $mkTextWind->destroy if Exists($mkTextWind);
    $mkTextWind = $top->Toplevel();
    dpos $mkTextWind;
    $mkTextWind->title('Text Demonstration - Embedded Windows');
    $mkTextWind->iconname('Embedded Windows');

    $mkTextWind_ok = $mkTextWind->Button(-text => 'OK', -command => ['destroy', $mkTextWind], -width => 8);
    $mkTextWind::w_t = $mkTextWind->Text(-setgrid => 'true', -width => 70, -height => 35, -wrap => 'word');
    my $w_s = $mkTextWind->Scrollbar(-command => ['yview', $mkTextWind::w_t]);
    $mkTextWind::w_t->configure(-yscrollcommand => ['set', $w_s]);
    $mkTextWind_ok->pack(-side => 'bottom');
    $w_s->pack(-side => 'right', -fill => 'y');
    $mkTextWind::w_t->pack(-expand => 'yes', -fill => 'both');
    $mkTextWind::w_t->tag('configure', 'bold', -font => '-Adobe-Courier-Bold-O-Normal--*-120-*-*-*-*-*-*');
    $mkTextWind::w_t->tag('configure', 'center', -justify => 'center', -spacing1 => '5m', -spacing3 => '5m');
    $mkTextWind::w_t->tag('configure', 'buttons', -lmargin1 => '1c', -lmargin2 =>'1c', -rmargin => '1c', -spacing1 => '3m',
			  -spacing2 => 0, -spacing3 => 0);

    my $w_t_on = $mkTextWind::w_t->Button(-text => 'Turn On', -command => \&textWindOn, -cursor => 'top_left_arrow');
    my $w_t_off = $mkTextWind::w_t->Button(-text => 'Turn Off', -command => \&textWindOff, -cursor => 'top_left_arrow');
    my $w_t_click = $mkTextWind::w_t->Button(-text => 'Click Here', -command => \&textWindPlot, -cursor => 'top_left_arrow');
    my $w_t_delete = $mkTextWind::w_t->Button(-text => 'Delete', -command => \&textWindDel, -cursor => 'top_left_arrow');

    $mkTextWind::w_t->insert('end', "A text widget can contain other widgets embedded ");
    $mkTextWind::w_t->insert('end', "it.  These are called ");
    $mkTextWind::w_t->insert('end', "embedded windows", 'bold');
    $mkTextWind::w_t->insert('end', ", and they can consist of arbitrary widgets.  ");
    $mkTextWind::w_t->insert('end', "For example, here are two embedded button ");
    $mkTextWind::w_t->insert('end', "widgets.  You can click on the first button to ");
    $mkTextWind::w_t->window('create', 'end', -window => $w_t_on);
    $mkTextWind::w_t->insert('end', " horizontal scrolling, which also turns off ");
    $mkTextWind::w_t->insert('end', "word wrapping.  Or, you can click on the second ");
    $mkTextWind::w_t->insert('end', "button to\n");
    $mkTextWind::w_t->window('create', 'end', -window => $w_t_off);
    $mkTextWind::w_t->insert('end', " horizontal scrolling and turn back on word wrapping.\n\n");

    $mkTextWind::w_t->insert('end', "Or, here is another example.  If you ");
    $mkTextWind::w_t->window('create', 'end', -window => $w_t_click);
    $mkTextWind::w_t->insert('end', " a canvas displaying an x-y plot will appear right here.");
    $mkTextWind::w_t->mark('set', 'plot', 'insert');
    $mkTextWind::w_t->mark('gravity', 'plot', 'left');
    $mkTextWind::w_t->insert('end', "  You can drag the data points around with the mouse, ");
    $mkTextWind::w_t->insert('end', "or you can click here to ");
    $mkTextWind::w_t->window('create', 'end', -window => $w_t_delete);
    $mkTextWind::w_t->insert('end', " the plot again.\n\n");

    $mkTextWind::w_t->insert('end', "You may also find it useful to put embedded windows in ");
    $mkTextWind::w_t->insert('end', "a text without any actual text.  In this case the ");
    $mkTextWind::w_t->insert('end', "text widget acts like a geometry manager.  For ");
    $mkTextWind::w_t->insert('end', "example, here is a collection of buttons laid out ");
    $mkTextWind::w_t->insert('end', "neatly into rows by the text widget.  These buttons ");
    $mkTextWind::w_t->insert('end', "can be used to change the background color of the ");
    $mkTextWind::w_t->insert('end', "text widget (\"Default\" restores the color to ");
    $mkTextWind::w_t->insert('end', "its default).  If you click on the button labeled ");
    $mkTextWind::w_t->insert('end', "\"Short\", it changes to a longer string so that ");
    $mkTextWind::w_t->insert('end', "you can see how the text widget automatically ");
    $mkTextWind::w_t->insert('end', "changes the layout.  Click on the button again ");
    $mkTextWind::w_t->insert('end', "to restore the short string.\n");

    my $w_t_default = $mkTextWind::w_t->Button(-text => 'Default', -command => [\&embDefBg, $mkTextWind::w_t],
				  -cursor => 'top_left_arrow');
    $mkTextWind::w_t->window('create', 'end', -window => $w_t_default, -padx => 3);
    $embToggle = 'Short';
    my $w_t_toggle = $mkTextWind::w_t->Checkbutton(-textvariable => \$embToggle, -indicatoron => 0, -variable => \$embToggle,
				      -onvalue => 'A much longer string', -offvalue => 'Short', -cursor => 'top_left_arrow');
    $mkTextWind::w_t->window('create', 'end', -window => $w_t_toggle, -padx => 3, -pady => 2);
    my($i, $color) = (1, '');
    foreach $color (qw(AntiqueWhite3 Bisque1 Bisque2 Bisque3 Bisque4 SlateBlue3 RoyalBlue1 SteelBlue2 DeepSkyBlue3 LightBlue1
		       DarkSlateGray1 Aquamarine2 DarkSeaGreen2 SeaGreen1 Yellow1 IndianRed1 IndianRed2 Tan1 Tan4)) {
	my $color_name = "w_t_color${i}";
	${$color_name} = $mkTextWind::w_t->Button(-text => "$color", -cursor => 'top_left_arrow');
        ${$color_name}->configure(-command => [sub {
	    shift->configure(@_);
	}, $mkTextWind::w_t, -background => $color]);
        $mkTextWind::w_t->window('create', 'end', -window => ${$color_name}, -padx => 3, -pady => 2);
        $i++;
    }
    $mkTextWind::w_t->tag('add', 'buttons', $w_t_default, 'end');

} # end mkTextWind





1;
