# twind.pl

BEGIN {unshift @INC, Tk->findINC('demos/widget_lib')};
require Plot;

sub twind_create_plot;
sub twind_delete_plot;
sub twind_hide_scroll;
sub twind_realize_scroll;
sub twind_restore_bg;

sub twind {

    # Create a top-level window with a text widget that demonstrates the
    # use of embedded windows in texts.

    my($demo) = @ARG;

    $TWIND->destroy if Exists($TWIND);
    $TWIND = $MW->Toplevel;
    my $w = $TWIND;
    dpos $w;
    $w->title('Text Demonstration - Embedded Windows');
    $w->iconname('twind');

    my $w_buttons = $w->Frame;
    $w_buttons->pack(qw(-side bottom -expand y -fill x -pady 2m));
    my $w_dismiss = $w_buttons->Button(
        -text               => 'Dismiss',
        -command            => [$w => 'destroy'],
    );
    $w_dismiss->pack(qw(-side left -expand 1));
    my $w_see = $w_buttons->Button(
        -text    => 'See Code',
        -command => [\&seeCode, $demo],
    );
    $w_see->pack(qw(-side left -expand 1));

    my $w_f = $w->Frame(
        -highlightthickness => 2, 
        -borderwidth        => 2,
	-relief             => 'sunken',
    );
    my $w_t = $w_f->Text(
        -font               => $FONT, 
        -setgrid            => 'true',
	-width              => 70, 
        -height             => 35, 
        -wrap               => 'word',
	-highlightthickness => 0, 
        -borderwidth        => 0,
    );
    $w_t->pack(-expand => 'yes', -fill => 'both');
    my $w_s = $w->Scrollbar(-command => [$w_t => 'yview']);
    $w_s->pack(-side => 'right', -fill => 'y');
    $w_f->pack(-expand => 'yes', -fill => 'both');
    my $w_s2 = $w->Scrollbar(
        -orient  => 'horizontal',
        -command => [$w_t => 'xview'],
    );
    $w_t->configure(-xscrollcommand => [$w_s2 => 'set']);
    $w_t->configure(-yscrollcommand => [$w_s => 'set']);

    $w_t->tag('configure', 'center', -justify => 'center',
			  -spacing1 => '5m', -spacing3 => '5m');
    $w_t->tag('configure', 'buttons', -lmargin1 => '1c',
			  -lmargin2 =>'1c', -rmargin => '1c',
			  -spacing1 => '3m', -spacing2 => 0, -spacing3 => 0);

    my $w_t_on = $w_t->Button(
        -text => 'Turn On',
        -command => [\&twind_realize_scroll, $w_s2, $w_t, $w_buttons],
        -cursor => 'top_left_arrow',
    );
    my $w_t_off = $w_t->Button(
        -text => 'Turn Off',
        -command => [\&twind_hide_scroll, $w_s2, $w_t],
	-cursor => 'top_left_arrow',
    );

    my $w_t_click = $w_t->Button(
        -text    => 'Click Here',
	-command => [\&twind_create_plot, $w_t],
	-cursor  => 'top_left_arrow',
    );
    my $w_t_delete = $w_t->Button(
        -text    => 'Delete',
	-command => [\&twind_delete_plot, $w_t],
	-cursor  => 'top_left_arrow',
    );

    $w_t->insert('end', "A text widget can contain other widgets embedded ");
    $w_t->insert('end', "in it.  These are called ");
    $w_t->insert('end', "\"embedded windows\"");
    $w_t->insert('end', ", and they can consist of arbitrary widgets.  ");
    $w_t->insert('end', "For example, here are two embedded button ");
    $w_t->insert('end', "widgets.  You can click on the first button to ");
    $w_t->window('create', 'end', -window => $w_t_on);
    $w_t->insert('end', " horizontal scrolling, which also turns off ");
    $w_t->insert('end', "word wrapping.  Or, you can click on the second ");
    $w_t->insert('end', "button to\n");
    $w_t->window('create', 'end', -window => $w_t_off);
    $w_t->insert('end', " horizontal scrolling and turn back on word ");
    $w_t->insert('end', "wrapping.\n\n");

    $w_t->insert('end', "Or, here is another example.  If you ");
    $w_t->window('create', 'end', -window => $w_t_click);
    $w_t->insert('end', " a canvas displaying an x-y plot will appear ");
    $w_t->insert('end', "right here.");
    $w_t->mark('set', 'plot', 'insert');
    $w_t->mark('gravity', 'plot', 'left');
    $w_t->insert('end', "  You can drag the data points around with the ");
    $w_t->insert('end', "mouse, or you can click here to ");
    $w_t->window('create', 'end', -window => $w_t_delete);
    $w_t->insert('end', " the plot again.\n\n");

    $w_t->insert('end', "You may also find it useful to put embedded windows");
    $w_t->insert('end', " in a text without any actual text.  In this case ");
    $w_t->insert('end', "the text widget acts like a geometry manager.  For ");
    $w_t->insert('end', "example, here is a collection of buttons laid out ");
    $w_t->insert('end', "neatly into rows by the text widget.  These buttons");
    $w_t->insert('end', " can be used to change the background color of the ");
    $w_t->insert('end', "text widget (\"Default\" restores the color to ");
    $w_t->insert('end', "its default).  If you click on the button labeled ");
    $w_t->insert('end', "\"Short\", it changes to a longer string so that ");
    $w_t->insert('end', "you can see how the text widget automatically ");
    $w_t->insert('end', "changes the layout.  Click on the button again ");
    $w_t->insert('end', "to restore the short string.\n");

    my $w_t_default = $w_t->Button(
        -text => 'Default',
	-command => [\&twind_restore_bg, $w_t],
	-cursor  => 'top_left_arrow',
    );
    $w_t->window('create', 'end', -window => $w_t_default, -padx => 3);
    $embToggle = 'Short';
    my $w_t_toggle = $w_t->Checkbutton(
        -textvariable => \$embToggle,
        -indicatoron  => 0, 
        -variable     => \$embToggle,
        -onvalue      => 'A much longer string',
        -offvalue     => 'Short',
        -cursor       => 'top_left_arrow',
    );
    $w_t->window('create', 'end', -window => $w_t_toggle,
			     -padx => 3, -pady => 2);
    my($i, $color) = (1, '');
    foreach $color (qw(AntiqueWhite3 Bisque1 Bisque2 Bisque3 Bisque4
		       SlateBlue3 RoyalBlue1 SteelBlue2 DeepSkyBlue3
		       LightBlue1 DarkSlateGray1 Aquamarine2 DarkSeaGreen2
		       SeaGreen1 Yellow1 IndianRed1 IndianRed2 Tan1 Tan4)) {
	my $color_name = "w_t_color${i}";
	${$color_name} = $w_t->Button(
            -text   => "$color",
	    -cursor => 'top_left_arrow',
        );
        ${$color_name}->configure(-command => [sub {
	    shift->configure(@ARG);
	}, $w_t, -background => $color]);
        $w_t->window('create', 'end', -window => ${$color_name},
                                 -padx => 3, -pady => 2);
        $i++;
    }
    $w_t->tag('add', 'buttons', $w_t_default, 'end');

} # end twind

sub twind_create_plot {

    # We are required to create a new Plot object everytime since embedded
    # widgets are destroyed when their tag is deleted. (Too bad.)

    my($text) = @ARG;

    if (not Exists($twind::plot)) {
        $twind::plot = $text->Plot(
	    -title_color        => 'Brown',
            -inactive_highlight => 'Skyblue2',
            -active_highlight   => 'red',
        );

        while ($text->get('plot') =~ / |\t|\n/) {
            $text->delete('plot');
	}
	$text->insert('plot', "\n");
	$text->window('create', 'plot', -window => $twind::plot);
	$text->tag('add', 'center', 'plot');
	$text->insert('plot', "\n");
    } # ifend 

} # end twind_create_plot

sub twind_delete_plot {

    my($text) = @ARG;

    if (Exists($twind::plot)) {
	$text->delete($twind::plot);
	while ($text->get('plot') =~ / |\t|\n/) {
	    $text->delete('plot');
	}
	$text->insert('plot', '  ');
    }

} # end twind_delete_plot

sub twind_hide_scroll {

    my($scroll, $text) = @ARG;

    $scroll->packForget;
    $text->configure(-wrap => 'word');

} # end twind_hide_scroll

sub twind_realize_scroll {

    my($scroll, $text, $buttons) = @ARG;

    $scroll->pack(
        '-after' => $buttons,
	-side    => 'bottom',
        -fill    => 'x',
    );
    $text->configure(-wrap => 'none');

} # end twind_realize_scroll

sub twind_restore_bg {

    my($text) = @ARG;

    $text->configure(-background => ($text->configure(-background))[3]);

} # end twind_restore_bg

1;
