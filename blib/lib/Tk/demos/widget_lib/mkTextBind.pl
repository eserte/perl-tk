

sub mkTextBind {

    # Create a top-level window that illustrates how you can bind Perl commands to regions of text in a text widget.

    $mkTextBind->destroy if Exists($mkTextBind);
    $mkTextBind = $top->Toplevel();
    my $w = $mkTextBind;
    dpos $w;
    $w->title('Text Demonstration - Tag Bindings');
    $w->iconname('Text Bindings');
    my $w_ok = $w->Button(-text => 'OK', -width => 8, -command => ['destroy', $w]);
    my $w_t = $w->Text(-setgrid => 'true', -width => '60', -height => '28',
			-font => '-Adobe-Helvetica-Bold-R-Normal--*-120-*-*-*-*-*-*');
    my $w_s = $w->Scrollbar(-command => ['yview', $w_t]);
    $w_t->configure(-yscrollcommand => ['set', $w_s]);
    $w_ok->pack(-side => 'bottom');
    $w_s->pack(-side => 'right', -fill => 'y');
    $w_t->pack(-expand => 'yes', -fill => 'both');

    # Set up display styles

    my(@bold, @normal, $tags);
    if ($mkTextBind->depth > 1) {
	@bold = (-foreground => 'red');
	@normal = (-foreground => undef);
    } else {
	@bold = (-foreground => 'white', -background => 'black');
	@normal = (-foreground => undef, -background => undef);
    }

    $w_t->insert('0.0', 'The same tag mechanism that controls display styles in text
widgets can also be used to associate Perl commands with regions
of text, so that mouse or keyboard actions on the text cause
particular Perl commands to be invoked.  For example, in the
text below the descriptions of the canvas demonstrations have
been tagged.  When you move the mouse over a demo description
the description lights up, and when you press button 3 over a
description then that particular demonstration is invoked.

This demo package contains a number of demonstrations of Tk\'s
canvas widgets.  Here are brief descriptions of some of the
demonstrations that are available:');
    insert_with_tags($w_t, "\n\n1. Samples of all the different types of items that can be\ncreated in canvas widgets.", 'd1');
    insert_with_tags($w_t, "\n\n2. A simple two-dimensional plot that allows you to adjust\n", 'd2');
    insert_with_tags($w_t, 'the positions of the data points.', 'd2');
    insert_with_tags($w_t, "\n\n3. Anchoring and justification modes for text items.", 'd3');
    insert_with_tags($w_t, "\n\n4. An editor for arrow-head shapes for line items.", 'd4');
    insert_with_tags($w_t, "\n\n5. A ruler with facilities for editing tab stops.", 'd5');
    insert_with_tags($w_t, "\n\n6. A grid that demonstrates how canvases can be scrolled.", 'd6');

    foreach $tag (qw(d1 d2 d3 d4 d5 d6)) {
	$w_t->tag('bind', $tag, '<Any-Enter>' => [sub {shift->tag('configure', shift, @_)}, $tag, @bold]);
	$w_t->tag('bind', $tag, '<Any-Leave>' => [sub {shift->tag('configure', shift, @_)}, $tag, @normal]);
    }
    $w_t->tag('bind', 'd1', '<3>', \&mkItems);
    $w_t->tag('bind', 'd2', '<3>', \&mkPlot);
    $w_t->tag('bind', 'd3', '<3>', \&mkCanvText);
    $w_t->tag('bind', 'd4', '<3>', \&mkArrow);
    $w_t->tag('bind', 'd5', '<3>', \&mkRuler);
    $w_t->tag('bind', 'd6', '<3>', \&mkScroll);

    $w_t->mark('set', 'insert', '0.0');

} # end mkTextBind


1;
