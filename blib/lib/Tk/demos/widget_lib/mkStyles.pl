

sub mkStyles {

    # Create a top-level window with a text widget that demonstrates the various display styles that are available in texts.

    $mkStyles->destroy if Exists($mkStyles);
    $mkStyles = $top->Toplevel();
    my $w = $mkStyles;
    dpos $w;
    $w->title('Text Demonstration - Display Styles');
    $w->iconname('Text Styles');

    my $w_ok = $w->Button(-text => 'OK', -width => 8, -command => ['destroy', $w]);
    my $w_t = $w->Text(-setgrid => 'true', -width => 70, -height => 28, -wrap => 'word');
    my $w_s = $w->Scrollbar(-command => ['yview', $w_t]);
    $w_t->configure(-yscrollcommand => ['set', $w_s]);
    $w_ok->pack(-side => 'bottom');
    $w_s->pack(-side => 'right', -fill => 'y');
    $w_t->pack(-expand => 'yes', -fill => 'both');

    # Set up display styles.

    $w_t->tag('configure', 'bold', -font => '-Adobe-Courier-Bold-O-Normal--*-120-*-*-*-*-*-*');
    $w_t->tag('configure', 'big', -font => '-Adobe-Courier-Bold-R-Normal--*-140-*-*-*-*-*-*');
    $w_t->tag('configure', 'verybig', -font => '-Adobe-Helvetica-Bold-R-Normal--*-240-*-*-*-*-*-*');
    if ($mkStyles->depth > 1) {
	$w_t->tag('configure', 'color1', -background => '#eed5b7');
	$w_t->tag('configure', 'color2', -foreground => 'red');
	$w_t->tag('configure', 'raised', -background => '#eed5b7', -relief => 'raised', -borderwidth => 1);
	$w_t->tag('configure', 'sunken', -background => '#eed5b7', -relief => 'sunken', -borderwidth => 1);
    } else {
	$w_t->tag('configure', 'color1', -background => 'black', -foreground => 'white');
	$w_t->tag('configure', 'color2', -background => 'black', -foreground => 'white');
	$w_t->tag('configure', 'raised', -background => 'white', -relief => 'raised', -borderwidth => 1);
	$w_t->tag('configure', 'sunken', -background => 'white', -relief => 'sunken', -borderwidth => 1);
    }
    $w_t->tag('configure', 'bgstipple', -background => 'black', -borderwidth => 0, -bgstipple => 'gray25');
    $w_t->tag('configure', 'fgstipple', -fgstipple => 'gray50');
    $w_t->tag('configure', 'underline', -underline => 'on');
    $w_t->tag('configure', 'overstrike', -overstrike => 'on');
    $w_t->tag('configure', 'right', -justify => 'right');
    $w_t->tag('configure', 'center', -justify => 'center');
    $w_t->tag('configure', 'super', -offset => '4p', -font => '-Adobe-Courier-Medium-R-Normal--*-100-*-*-*-*-*-*');
    $w_t->tag('configure', 'sub', -offset => '-2p', -font => '-Adobe-Courier-Medium-R-Normal--*-100-*-*-*-*-*-*');
    $w_t->tag('configure', 'margins', -lmargin1 => '12m', -lmargin2 => '6m', -rmargin => '10m');
    $w_t->tag('configure', 'spacing', -spacing1 => '10p', -spacing2 => '2p',-lmargin1 => '12m', -lmargin2 => '6m', -rmargin => '10m');

    $w_t->insert('0.0', 'Text widgets like this one allow you to display information in a
variety of styles.  Display styles are controlled using a mechanism
called ');
    insert_with_tags($w_t, 'tags', qw(bold));
    insert_with_tags($w_t, '. Tags are just textual names that you can apply to one
or more ranges of characters within a text widget.  You can configure
tags with various display styles.  If you do this, then the tagged
characters will be displayed with the styles you chose.  The
available display styles are:  ');
    insert_with_tags($w_t, "\n\n1. Font.", qw(big));
    insert_with_tags($w_t, '  You can choose any X font, ');
    insert_with_tags($w_t, 'large', qw(verybig));
    insert_with_tags($w_t, ' or small.');
    insert_with_tags($w_t, "\n\n2. Color.", qw(big));
    insert_with_tags($w_t, '  You can change either the ');
    insert_with_tags($w_t, 'background', qw(color1));
    insert_with_tags($w_t, ' or ');
    insert_with_tags($w_t, 'foreground', qw(color2));
    insert_with_tags($w_t, "\ncolor, or ");
    insert_with_tags($w_t, 'both', qw(color1 color2));
    insert_with_tags($w_t, '.');
    insert_with_tags($w_t, "\n\n3. Stippling.", qw(big));
    insert_with_tags($w_t, '  You can cause either the ');
    insert_with_tags($w_t, 'background', qw(bgstipple));
    insert_with_tags($w_t, ' or ');
    insert_with_tags($w_t, 'foreground', qw(fgstipple));
    insert_with_tags($w_t, "\ninformation to be drawn with a stipple fill instead of a solid fill.");
    insert_with_tags($w_t, "\n\n4. Underlining.", qw(big));
    insert_with_tags($w_t, '  You can ');
    insert_with_tags($w_t, 'underline', qw(underline));
    insert_with_tags($w_t, ' ranges of text.');
    insert_with_tags($w_t, "\n\n5. Overstrikes.", 'big');
    insert_with_tags($w_t, "  You can ");
    insert_with_tags($w_t, "draw lines through", 'overstrike');
    insert_with_tags($w_t, " ranges of text.");
    insert_with_tags($w_t, "\n\n6. 3-D effects.", qw( big));
    insert_with_tags($w_t, "  You can arrange for the background to be drawn\n");
    insert_with_tags($w_t, 'with a border that makes characters appear either ');
    insert_with_tags($w_t, 'raised', qw(raised));
    insert_with_tags($w_t, ' or ');
    insert_with_tags($w_t, 'sunken', qw(sunken));
    insert_with_tags($w_t, '.');
    insert_with_tags($w_t, "\n\n7. Justification.", 'big');
    insert_with_tags($w_t, " You can arrange for lines to be displayed\n");
    insert_with_tags($w_t, "left-justified,\n");
    insert_with_tags($w_t, "right-justified, or\n", 'right');
    insert_with_tags($w_t, "centered.", 'center');
    insert_with_tags($w_t, "\n\n8. Superscripts and subscripts." , 'big');
    insert_with_tags($w_t, " You can control the vertical\n");
    insert_with_tags($w_t, "position of text to generate superscript effects like 10");
    insert_with_tags($w_t, "n", 'super');
    insert_with_tags($w_t, " or\nsubscript effects like X");
    insert_with_tags($w_t, "i", 'sub');
    insert_with_tags($w_t, ".");
    insert_with_tags($w_t, "\n\n9. Margins.", 'big');
    insert_with_tags($w_t, " You can control the amount of extra space left");
    insert_with_tags($w_t, " on\neach side of the text:\n");
    insert_with_tags($w_t, "This paragraph is an example of the use of ", 'margins');
    insert_with_tags($w_t, "margins.  It consists of a single line of text ", 'margins');
    insert_with_tags($w_t, "that wraps around on the screen.  There are two ", 'margins');
    insert_with_tags($w_t, "separate left margin values, one for the first ", 'margins');
    insert_with_tags($w_t, "display line associated with the text line, ", 'margins');
    insert_with_tags($w_t, "and one for the subsequent display lines, which ", 'margins');
    insert_with_tags($w_t, "occur because of wrapping.  There is also a ", 'margins');
    insert_with_tags($w_t, "separate specification for the right margin, ", 'margins');
    insert_with_tags($w_t, "which is used to choose wrap points for lines.", 'margins');
    insert_with_tags($w_t, "\n\n10. Spacing.", 'big');
    insert_with_tags($w_t, " You can control the spacing of lines with three\n");
    insert_with_tags($w_t, "separate parameters.  \"Spacing1\" tells how much ");
    insert_with_tags($w_t, "extra space to leave\nabove a line, \"spacing3\" ");
    insert_with_tags($w_t, "tells how much space to leave below a line,\nand ");
    insert_with_tags($w_t, "if a text line wraps, \"spacing2\" tells how much ");
    insert_with_tags($w_t, "space to leave\nbetween the display lines that ");
    insert_with_tags($w_t, "make up the text line.\n");
    insert_with_tags($w_t, "These indented paragraphs illustrate how spacing ", 'spacing');
    insert_with_tags($w_t, "can be used.  Each paragraph is actually a ", 'spacing');
    insert_with_tags($w_t, "single line in the text widget, which is ", 'spacing');
    insert_with_tags($w_t, "word-wrapped by the widget.\n", 'spacing');
    insert_with_tags($w_t, "Spacing1 is set to 10 points for this text, ", 'spacing');
    insert_with_tags($w_t, "which results in relatively large gaps between ", 'spacing');
    insert_with_tags($w_t, "the paragraphs. Spacing2 is set to 2 points, ", 'spacing');
    insert_with_tags($w_t, "which results in just a bit of extra space ", 'spacing');
    insert_with_tags($w_t, "within a pararaph.  Spacing3 isn't used ", 'spacing');
    insert_with_tags($w_t, "in this example.\n", 'spacing');
    insert_with_tags($w_t, "To see where the space is, select ranges of ", 'spacing');
    insert_with_tags($w_t, "text within these paragraphs.  The selection ", 'spacing');
    insert_with_tags($w_t, "highlight will cover the extra space.", 'spacing');

    $w_t->mark('set', 'insert', '0.0');

} # end mkStyles


1;
