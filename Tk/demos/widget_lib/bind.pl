# bind.pl

sub bind {

    # Create a top-level window that illustrates how you can bind Perl
    # commands to regions of text in a text widget.

    my($demo) = @ARG;

    $BIND->destroy if Exists($BIND);
    $BIND = $mw->Toplevel;
    my $w = $BIND;
    dpos $w;
    $w->title('Text Demonstration - Tag Bindings');
    $w->iconname('bind');

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

    my $w_t = $w->Text(-setgrid => 'true', -width => '60', -height => '24',
			-font => $FONT, -wrap => 'word');
    my $w_s = $w->Scrollbar(-command => ['yview', $w_t]);
    $w_t->configure(-yscrollcommand => ['set', $w_s]);
    $w_s->pack(-side => 'right', -fill => 'y');
    $w_t->pack(-expand => 'yes', -fill => 'both');

    # Set up display styles

    my(@bold, @normal, $tags);
    if ($w->depth > 1) {
	@bold = (-background => '#43ce80', -relief => 'raised',
		 -borderwidth => 1);
	@normal = (-background => undef, -relief => 'flat');
    } else {
	@bold = (-foreground => 'white', -background => 'black');
	@normal = (-foreground => undef, -background => undef);
    }

    $w_t->insert('0.0', 'The same tag mechanism that controls display styles in text widgets can also be used to associate Tcl commands with regions of text, so that mouse or keyboard actions on the text cause particular Tcl commands to be invoked.  For example, in the text below the descriptions of the canvas demonstrations have been tagged.  When you move the mouse over a demo description the description lights up, and when you press button 1 over a description then that particular demonstration is invoked.

');
    $w_t->insert('end','1. Samples of all the different types of items that can be created in canvas widgets.', 'd1');
    $w_t->insert('end', "\n\n");
    $w_t->insert('end', '2. A simple two-dimensional plot that allows you to adjust the positions of the data points.', 'd2');
    $w_t->insert('end', "\n\n");
    $w_t->insert('end', '3. Anchoring and justification modes for text items.', 'd3');
    $w_t->insert('end', "\n\n");
    $w_t->insert('end', '4. An editor for arrow-head shapes for line items.', 'd4');
    $w_t->insert('end', "\n\n");
    $w_t->insert('end', '5. A ruler with facilities for editing tab stops.', 'd5');
    $w_t->insert('end', "\n\n");
    $w_t->insert('end', '6. A grid that demonstrates how canvases can be scrolled.', 'd6');

    foreach $tag (qw(d1 d2 d3 d4 d5 d6)) {
	$w_t->tag('bind', $tag, '<Any-Enter>' => [
            sub {
		shift->tag('configure', shift, @ARG);
	    }, $tag, @bold],
        );
	$w_t->tag('bind', $tag, '<Any-Leave>' => [
            sub {
		shift->tag('configure', shift, @ARG);
            }, $tag, @normal],
        );
    }
    $w_t->tag('bind', 'd1', '<1>' => sub {&items('items')});
    $w_t->tag('bind', 'd2', '<1>' => sub {\&plot('plot')});
    $w_t->tag('bind', 'd3', '<1>' => sub {\&ctext('ctext')});
    $w_t->tag('bind', 'd4', '<1>' => sub {\&arrows('arrows')});
    $w_t->tag('bind', 'd5', '<1>' => sub {\&ruler('ruler')});
    $w_t->tag('bind', 'd6', '<1>' => sub {\&ccroll('cscroll')});

    $w_t->mark('set', 'insert', '0.0');

} # end bind

1;
