# style.pl

sub style {

    # Create a top-level window with a text widget that demonstrates 
    # the various display styles that are available in texts.

    my($demo) = @ARG;

    $STYLE->destroy if Exists($STYLE);
    $STYLE = $MW->Toplevel;
    my $w = $STYLE;
    dpos $w;
    $w->title('Text Demonstration - Display Styles');
    $w->iconname('style');

    my $w_buttons = $w->Frame;
    $w_buttons->pack(qw(-side bottom -fill x -pady 2m));
    my $w_dismiss = $w_buttons->Button(
        -text    => 'Dismiss',
        -command => [$w => 'destroy'],
    );
    $w_dismiss->pack(qw(-side left -expand 1));
    my $w_see = $w_buttons->Button(
        -text    => 'See Code',
        -command => [\&see_code, $demo],
    );
    $w_see->pack(qw(-side left -expand 1));

    my $w_t = $w->Text(-setgrid => 'true', -width => 70, -height => 32,
		       -wrap => 'word');
    my $w_s = $w->Scrollbar(-command => [$w_t => 'yview']);
    $w_t->configure(-yscrollcommand => [$w_s => 'set']);
    $w_s->pack(-side => 'right', -fill => 'y');
    $w_t->pack(-expand => 'yes', -fill => 'both');

    # Set up display styles.

    $w_t->tag('configure', 'bold',
	      -font => '-*-Courier-Bold-O-Normal-*-120-*-*-*-*-*-*');
    $w_t->tag('configure', 'big',
	      -font => '-*-Courier-Bold-R-Normal-*-140-*-*-*-*-*-*');
    $w_t->tag('configure', 'verybig',
	      -font => '-*-Helvetica-Bold-R-Normal-*-240-*-*-*-*-*-*');
    if ($w->depth > 1) {
	$w_t->tag('configure', 'color1', -background => '#a0b7ce');
	$w_t->tag('configure', 'color2', -foreground => 'red');
	$w_t->tag('configure', 'raised', -relief => 'raised',
		  -borderwidth => 1);
	$w_t->tag('configure', 'sunken', -relief => 'sunken',
		  -borderwidth => 1);
    } else {
	$w_t->tag('configure', 'color1', -background => 'black',
		  -foreground => 'white');
	$w_t->tag('configure', 'color2', -background => 'black',
		  -foreground => 'white');
	$w_t->tag('configure', 'raised', -background => 'white',
		  -relief => 'raised', -borderwidth => 1);
	$w_t->tag('configure', 'sunken', -background => 'white',
		  -relief => 'sunken', -borderwidth => 1);
    }
    $w_t->tag('configure', 'bgstipple', -background => 'black',
	      -borderwidth => 0, -bgstipple => 'gray25');
    $w_t->tag('configure', 'fgstipple', -fgstipple => 'gray50');
    $w_t->tag('configure', 'underline', -underline => 'on');
    $w_t->tag('configure', 'overstrike', -overstrike => 'on');
    $w_t->tag('configure', 'right', -justify => 'right');
    $w_t->tag('configure', 'center', -justify => 'center');
    $w_t->tag('configure', 'super', -offset => '4p',
	      -font => '-*-Courier-Medium-R-Normal--*-100-*-*-*-*-*-*');
    $w_t->tag('configure', 'sub', -offset => '-2p',
	      -font => '-*-Courier-Medium-R-Normal--*-100-*-*-*-*-*-*');
    $w_t->tag('configure', 'margins', -lmargin1 => '12m', -lmargin2 => '6m',
	      -rmargin => '10m');
    $w_t->tag('configure', 'spacing', -spacing1 => '10p', -spacing2 => '2p',
	      -lmargin1 => '12m', -lmargin2 => '6m', -rmargin => '10m');

    $w_t->insert('0.0',
'Text widgets like this one allow you to display information in a
variety of styles.  Display styles are controlled using a mechanism
called ');
    inswt($w_t, 'tags', qw(bold));
    inswt($w_t,
'. Tags are just textual names that you can apply to one
or more ranges of characters within a text widget.  You can configure
tags with various display styles.  If you do this, then the tagged
characters will be displayed with the styles you chose.  The
available display styles are:  ');
    inswt($w_t, "\n\n1. Font.", qw(big));
    inswt($w_t, '  You can choose any X font, ');
    inswt($w_t, 'large', qw(verybig));
    inswt($w_t, ' or small.');
    inswt($w_t, "\n\n2. Color.", qw(big));
    inswt($w_t, '  You can change either the ');
    inswt($w_t, 'background', qw(color1));
    inswt($w_t, ' or ');
    inswt($w_t, 'foreground', qw(color2));
    inswt($w_t, "\ncolor, or ");
    inswt($w_t, 'both', qw(color1 color2));
    inswt($w_t, '.');
    inswt($w_t, "\n\n3. Stippling.", qw(big));
    inswt($w_t, '  You can cause either the ');
    inswt($w_t, 'background', qw(bgstipple));
    inswt($w_t, ' or ');
    inswt($w_t, 'foreground', qw(fgstipple));
    inswt($w_t, "\ninformation to be drawn with a stipple fill instead of a solid fill.");
    inswt($w_t, "\n\n4. Underlining.", qw(big));
    inswt($w_t, '  You can ');
    inswt($w_t, 'underline', qw(underline));
    inswt($w_t, ' ranges of text.');
    inswt($w_t, "\n\n5. Overstrikes.", 'big');
    inswt($w_t, "  You can ");
    inswt($w_t, "draw lines through", 'overstrike');
    inswt($w_t, " ranges of text.");
    inswt($w_t, "\n\n6. 3-D effects.", qw( big));
    inswt($w_t, "  You can arrange for the background to be drawn\n");
    inswt($w_t, 'with a border that makes characters appear either ');
    inswt($w_t, 'raised', qw(raised));
    inswt($w_t, ' or ');
    inswt($w_t, 'sunken', qw(sunken));
    inswt($w_t, '.');
    inswt($w_t, "\n\n7. Justification.", 'big');
    inswt($w_t, " You can arrange for lines to be displayed\n");
    inswt($w_t, "left-justified,\n");
    inswt($w_t, "right-justified, or\n", 'right');
    inswt($w_t, "centered.", 'center');
    inswt($w_t, "\n\n8. Superscripts and subscripts." , 'big');
    inswt($w_t, " You can control the vertical\n");
    inswt($w_t, "position of text to generate superscript effects like 10");
    inswt($w_t, "n", 'super');
    inswt($w_t, " or\nsubscript effects like X");
    inswt($w_t, "i", 'sub');
    inswt($w_t, ".");
    inswt($w_t, "\n\n9. Margins.", 'big');
    inswt($w_t, " You can control the amount of extra space left");
    inswt($w_t, " on\neach side of the text:\n");
    inswt($w_t, "This paragraph is an example of the use of ", 'margins');
    inswt($w_t, "margins.  It consists of a single line of text ", 'margins');
    inswt($w_t, "that wraps around on the screen.  There are two ", 'margins');
    inswt($w_t, "separate left margin values, one for the first ", 'margins');
    inswt($w_t, "display line associated with the text line, ", 'margins');
    inswt($w_t, "and one for the subsequent display lines, which ", 'margins');
    inswt($w_t, "occur because of wrapping.  There is also a ", 'margins');
    inswt($w_t, "separate specification for the right margin, ", 'margins');
    inswt($w_t, "which is used to choose wrap points for lines.", 'margins');
    inswt($w_t, "\n\n10. Spacing.", 'big');
    inswt($w_t, " You can control the spacing of lines with three\n");
    inswt($w_t, "separate parameters.  \"Spacing1\" tells how much ");
    inswt($w_t, "extra space to leave\nabove a line, \"spacing3\" ");
    inswt($w_t, "tells how much space to leave below a line,\nand ");
    inswt($w_t, "if a text line wraps, \"spacing2\" tells how much ");
    inswt($w_t, "space to leave\nbetween the display lines that ");
    inswt($w_t, "make up the text line.\n");
    inswt($w_t, "These indented paragraphs illustrate how spacing ", 'spacing');
    inswt($w_t, "can be used.  Each paragraph is actually a ", 'spacing');
    inswt($w_t, "single line in the text widget, which is ", 'spacing');
    inswt($w_t, "word-wrapped by the widget.\n", 'spacing');
    inswt($w_t, "Spacing1 is set to 10 points for this text, ", 'spacing');
    inswt($w_t, "which results in relatively large gaps between ", 'spacing');
    inswt($w_t, "the paragraphs. Spacing2 is set to 2 points, ", 'spacing');
    inswt($w_t, "which results in just a bit of extra space ", 'spacing');
    inswt($w_t, "within a pararaph.  Spacing3 isn't used ", 'spacing');
    inswt($w_t, "in this example.\n", 'spacing');
    inswt($w_t, "To see where the space is, select ranges of ", 'spacing');
    inswt($w_t, "text within these paragraphs.  The selection ", 'spacing');
    inswt($w_t, "highlight will cover the extra space.", 'spacing');

    $w_t->mark('set', 'insert', '0.0');

} # end style

1;
