# style.pl

use vars qw/$TOP/;

sub style {

    # Create a top-level window with a text widget that demonstrates 
    # the various display styles that are available in texts.

    my($demo) = @_;
    my $demo_widget = $MW->WidgetDemo(
        -name     => $demo,
        -text     =>'',				      
        -title    => 'Text Demonstration - Display Styles',
        -iconname => 'style',
    );
    $TOP = $demo_widget->Top;	# get geometry master

    my $t = $TOP->Scrolled(qw/Text -setgrid true -width  70 -height 32
			   -wrap word -scrollbars e/);
    $t->pack(qw/-expand yes -fill both/);

    # Set up display styles.

    $t->tag(qw/configure bold
	      -font -*-Courier-Bold-O-Normal--*-120-*-*-*-*-*-*/);
    $t->tag(qw/configure big
	      -font -*-Courier-Bold-R-Normal--*-140-*-*-*-*-*-*/);
    $t->tag(qw/configure verybig
	      -font -*-Helvetica-Bold-R-Normal--*-240-*-*-*-*-*-*/);
    if ($TOP->depth > 1) {
	$t->tag(qw/configure color1 -background/ => '#a0b7ce');
	$t->tag(qw/configure color2 -foreground red/);
	$t->tag(qw/configure raised -relief raised -borderwidth 1/);
	$t->tag(qw/configure sunken -relief sunken -borderwidth 1/);
    } else {
	$t->tag(qw/configure color1 -background black -foreground white/);
	$t->tag(qw/configure color2 -background black -foreground white/);
	$t->tag(qw/configure raised -background white -relief raised -bd 1/);
	$t->tag(qw/configure sunken -background white -relief sunken -bd 1/);
    }
    $t->tag(qw/configure bgstipple -background black  -borderwidth 0
	    -bgstipple gray25/);
    $t->tag(qw/configure fgstipple -fgstipple gray50/);
    $t->tag(qw/configure underline -underline on/);
    $t->tag(qw/configure overstrike -overstrike on/);
    $t->tag(qw/configure right -justify right/);
    $t->tag(qw/configure center -justify center/);
    $t->tag(qw/configure super -offset 4p
	    -font -*-Courier-Medium-R-Normal--*-100-*-*-*-*-*-*/);
    $t->tag(qw/configure sub -offset -2p
	    -font -*-Courier-Medium-R-Normal--*-100-*-*-*-*-*-*/);
    $t->tag(qw/configure margins -lmargin1 12m -lmargin2 6m -rmargin 10m/);
    $t->tag(qw/configure spacing -spacing1 10p -spacing2 2p
	    -lmargin1 12m -lmargin2 6m -rmargin 10m/);

    $t->insert('0.0',
'Text widgets like this one allow you to display information in a
variety of styles.  Display styles are controlled using a mechanism
called ');
    inswt($t, 'tags', qw(bold));
    inswt($t,
'. Tags are just textual names that you can apply to one
or more ranges of characters within a text widget.  You can configure
tags with various display styles.  If you do this, then the tagged
characters will be displayed with the styles you chose.  The
available display styles are:  ');
    inswt($t, "\n\n1. Font.", qw(big));
    inswt($t, '  You can choose any X font, ');
    inswt($t, 'large', qw(verybig));
    inswt($t, ' or small.');
    inswt($t, "\n\n2. Color.", qw(big));
    inswt($t, '  You can change either the ');
    inswt($t, 'background', qw(color1));
    inswt($t, ' or ');
    inswt($t, 'foreground', qw(color2));
    inswt($t, "\ncolor, or ");
    inswt($t, 'both', qw(color1 color2));
    inswt($t, '.');
    inswt($t, "\n\n3. Stippling.", qw(big));
    inswt($t, '  You can cause either the ');
    inswt($t, 'background', qw(bgstipple));
    inswt($t, ' or ');
    inswt($t, 'foreground', qw(fgstipple));
    inswt($t, "\ninformation to be drawn with a stipple fill instead of a solid fill.");
    inswt($t, "\n\n4. Underlining.", qw(big));
    inswt($t, '  You can ');
    inswt($t, 'underline', qw(underline));
    inswt($t, ' ranges of text.');
    inswt($t, "\n\n5. Overstrikes.", 'big');
    inswt($t, "  You can ");
    inswt($t, "draw lines through", 'overstrike');
    inswt($t, " ranges of text.");
    inswt($t, "\n\n6. 3-D effects.", qw( big));
    inswt($t, "  You can arrange for the background to be drawn\n");
    inswt($t, 'with a border that makes characters appear either ');
    inswt($t, 'raised', qw(raised));
    inswt($t, ' or ');
    inswt($t, 'sunken', qw(sunken));
    inswt($t, '.');
    inswt($t, "\n\n7. Justification.", 'big');
    inswt($t, " You can arrange for lines to be displayed\n");
    inswt($t, "left-justified,\n");
    inswt($t, "right-justified, or\n", 'right');
    inswt($t, "centered.", 'center');
    inswt($t, "\n\n8. Superscripts and subscripts." , 'big');
    inswt($t, " You can control the vertical\n");
    inswt($t, "position of text to generate superscript effects like 10");
    inswt($t, "n", 'super');
    inswt($t, " or\nsubscript effects like X");
    inswt($t, "i", 'sub');
    inswt($t, ".");
    inswt($t, "\n\n9. Margins.", 'big');
    inswt($t, " You can control the amount of extra space left");
    inswt($t, " on\neach side of the text:\n");
    inswt($t, "This paragraph is an example of the use of ", 'margins');
    inswt($t, "margins.  It consists of a single line of text ", 'margins');
    inswt($t, "that wraps around on the screen.  There are two ", 'margins');
    inswt($t, "separate left margin values, one for the first ", 'margins');
    inswt($t, "display line associated with the text line, ", 'margins');
    inswt($t, "and one for the subsequent display lines, which ", 'margins');
    inswt($t, "occur because of wrapping.  There is also a ", 'margins');
    inswt($t, "separate specification for the right margin, ", 'margins');
    inswt($t, "which is used to choose wrap points for lines.", 'margins');
    inswt($t, "\n\n10. Spacing.", 'big');
    inswt($t, " You can control the spacing of lines with three\n");
    inswt($t, "separate parameters.  \"Spacing1\" tells how much ");
    inswt($t, "extra space to leave\nabove a line, \"spacing3\" ");
    inswt($t, "tells how much space to leave below a line,\nand ");
    inswt($t, "if a text line wraps, \"spacing2\" tells how much ");
    inswt($t, "space to leave\nbetween the display lines that ");
    inswt($t, "make up the text line.\n");
    inswt($t, "These indented paragraphs illustrate how spacing ", 'spacing');
    inswt($t, "can be used.  Each paragraph is actually a ", 'spacing');
    inswt($t, "single line in the text widget, which is ", 'spacing');
    inswt($t, "word-wrapped by the widget.\n", 'spacing');
    inswt($t, "Spacing1 is set to 10 points for this text, ", 'spacing');
    inswt($t, "which results in relatively large gaps between ", 'spacing');
    inswt($t, "the paragraphs. Spacing2 is set to 2 points, ", 'spacing');
    inswt($t, "which results in just a bit of extra space ", 'spacing');
    inswt($t, "within a pararaph.  Spacing3 isn't used ", 'spacing');
    inswt($t, "in this example.\n", 'spacing');
    inswt($t, "To see where the space is, select ranges of ", 'spacing');
    inswt($t, "text within these paragraphs.  The selection ", 'spacing');
    inswt($t, "highlight will cover the extra space.", 'spacing');

    $t->mark(qw/set insert 0.0/);

} # end style

1;
