# ctext.pl

sub mkTextConfig;
sub textBs;
sub textB1Move;
sub textB1Press;
sub textEnter;

$ctext::::textConfigFill = '';

sub ctext {

    # Create a window containing a canvas displaying a text string and
    # allowing the string to be edited and re-anchored.

    my($demo) = @ARG;

    $CTEXT->destroy if Exists($CTEXT);
    $CTEXT = $mw->Toplevel;
    my $w = $CTEXT;
    dpos $w;
    $w->title('Canvas Text Demonstration');
    $w->iconname('ctext');
 
    my $w_msg = $w->Label(
        -font       => $FONT,
        -wraplength => '5i',
        -justify    => 'left',
			  -text       => 'This window displays a string of text to demonstrate the text facilities of canvas widgets.  You can click in the boxes to adijust the position of the text relative to its positioning point or change its justification.  The text also supports the following simple bindings for editing:
  1. You can point, click, and type.
  2. You can also select with button 1.
  3. You can copy the selection to the mouse position with button 2.
  4. Backspace and Control+h delete the character just before the
  insertion cursor.
  5. Delete deletes the character just after the insertion cursor.',
    );
    $w_msg->pack(-side => 'top');

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

    my $c = $w->Canvas(-relief => 'flat', -bd => 0, -width => '500',
		       -height => '400');
    $c->pack(-side => 'top', -expand => 'yes', -fill => 'both');

    $c->create(qw(rectangle 245 195 255 205 -outline black -fill red));

    # First, create the text item and give it bindings so it can be edited.
	
    $c->addtag('text', 'withtag',
        $c->create('text', 250, 200,
            -text      => 'This is just a string of text to demonstrate the text facilities of canvas widgets. You can point, click, and type.  You can also select and then delete with Control-d.',
             -width    => 440,
             -anchor   => 'n',
             -font     => '-*-helvetica-medium-r-*-240-*-*-*-*-*-*',
             -justify  => 'left',
        ),
    );
    $c->bind('text', '<1>' => sub {textB1Press(@ARG)});
    $c->bind('text', '<B1-Motion>' => sub {textB1Move(@ARG)});
    $c->bind('text', '<Shift-1>' => sub {
	my($c) = @ARG;
        my $e = $c->XEvent;
	my($x, $y) = ($e->x, $e->y);
	$c->select('adjust', 'current', "\@$x,$y");
    });
    $c->bind('text', '<Shift-B1-Motion>' => sub {textB1Move(@ARG)});
    $c->bind('text', '<KeyPress>' => sub {
	my($c) = @ARG;
        my $e = $c->XEvent;
	my $A = $e->A;
	$c->insert('text', 'insert', "$A");
    });
    $c->bind('text', '<Return>' => sub {
	my($c) = @ARG;
	$c->insert('text', 'insert', "\\n");
    });
    $c->bind('text', '<Control-h>' => sub {textBs(@ARG)});
    $c->bind('text', '<BackSpace>' => sub {textBs(@ARG)});
    $c->bind('text', '<Delete>' => sub {
	my($c) = @ARG;
	eval {$c->dchars('text', 'sel.first', 'sel.last')};
	$c->dchars('text', 'insert');
    });
    $c->bind('text', '<2>' => sub {
	my($c) = @ARG;
        my $e = $c->XEvent;
	$c->insert('text', $e->xy, $mw->SelectionGet);
    });

    # Next, create some items that allow the text's anchor position to
    # be edited.

    my($x, $y, $color) = (50, 50, 'LightSkyBlue1');
    mkTextConfig $c, $x,    $y,    -anchor => 'se',      $color;
    mkTextConfig $c, $x+30, $y,    -anchor => 's',       $color;
    mkTextConfig $c, $x+60, $y,    -anchor => 'sw',      $color;
    mkTextConfig $c, $x,    $y+30, -anchor => 'e',       $color;
    mkTextConfig $c, $x+30, $y+30, -anchor => 'center',  $color;
    mkTextConfig $c, $x+60, $y+30, -anchor => 'w',       $color;
    mkTextConfig $c, $x,    $y+60, -anchor => 'ne',      $color;
    mkTextConfig $c, $x+30, $y+60, -anchor => 'n',       $color;
    mkTextConfig $c, $x+60, $y+60, -anchor => 'nw',      $color;
    my $item = $c->create('rectangle', $x+40, $y+40, $x+50, $y+50,
			  -outline => 'black', -fill => 'red');
    $c->bind($item, '<1>' => sub {
	my($c) = @ARG;
	$c->itemconfigure('text', -anchor => 'center');
    });
    $c->create('text', $x+45, $y-5, -text => 'Text Position', -anchor => 's',
	       -font => '-*-times-medium-r-normal--*-240-*-*-*-*-*-*',
	       -fill => 'brown');

    # Lastly, create some items that allow the text's justification
    # to be changed.
    
    $x = 350; $y = 50; $color = 'SeaGreen2';
    mkTextConfig $c, $x,    $y,    -justify => 'left',   $color;
    mkTextConfig $c, $x+30, $y,    -justify => 'center', $color;
    mkTextConfig $c, $x+60, $y,    -justify => 'right',  $color;
    $c->create('text', $x+45, $y-5, -text => 'Justification', -anchor => 's',
	       -font => '-*-times-medium-r-normal--*-240-*-*-*-*-*-*',
	       -fill => 'brown');

    $c->bind('config', '<Enter>' =>  sub {textEnter(@ARG)});
    $c->bind('config', '<Leave>' => sub {
	my($c) = @ARG;
	$c->itemconfigure('current', -fill => $ctext::::textConfigFill);
    });

} # end ctext

sub mkTextConfig {

    my($w, $x, $y, $option, $value, $color) = @ARG;

    my $item = $w->create('rectangle', $x, $y, $x+30, $y+30,
			  -outline => 'black', -fill => $color, -width => 1);
    $w->bind($item, '<1>', [sub {
	my($w, $option, $value) = @ARG;

	$w->itemconfigure('text', $option => $value);
    }, $option, $value]);
    $w->addtag('config', 'withtag', $item);

} # end mkTextConfig

sub textEnter {

    my($w) = @ARG;

    $ctext::::textConfigFill =  ($w->itemconfigure('current', -fill))[4];
    $w->itemconfigure('current', -fill => 'black');

} # end textEnter

sub textB1Press {

    my($w) = @ARG;
    my $e = $w->XEvent;

    my($x, $y) = ($e->x, $e->y);
    $w->icursor('current', "\@$x,$y");
    $w->focus('current');
    $w->Tk::focus;
    $w->select('from', 'current', "\@$x,$y");

} # end textB1Press

sub textB1Move {

    my($w) = @ARG;
    my $e = $w->XEvent;

    my($x, $y) = ($e->x, $e->y);
    $w->select('to', 'current', "\@$x,$y");

} # end textB1Move

sub textBs {

    my($c) = @ARG;

    eval {$c->dchars('text', 'sel.first', 'sel.last')};
    my $char = $c->index('text', 'insert') - 1;
    $c->dchars('text', $char) if $char >= 0;

} # end textBs

1;


