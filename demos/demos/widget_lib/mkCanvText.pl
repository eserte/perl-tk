
sub mkTextConfig;
sub textBs;
sub textB1Move;
sub textB1Press;
sub textEnter;

sub mkCanvText {

    # Create a window containing a canvas displaying a text string and allowing the string to be edited and re-anchored.

    $mkCanvText->destroy if Exists($mkCanvText);
    $mkCanvText = $top->Toplevel();
    my $w = $mkCanvText;
    dpos $w;
    $w->title('Canvas Text Demonstration');
    $w->iconname('Text');

    my $w_msg = $w->Label(-font => '-Adobe-Times-Medium-R-Normal--*-180-*-*-*-*-*-*', -wraplength => '5i',
			   -justify => 'left', -text => 'This window displays a string of text to demonstrate the text ' .
			   'facilities of canvas widgets.  You can point, click, and type.  You can also select and then ' .
			   'delete with Control-d.  You can copy the selection with Control-v.  You can click in the boxes ' .
			   'to adjust the position of the text relative to its positioning point or change its justification.');
    my $c = $w->Canvas(-relief => 'flat', -bd => 0, -width => '500', -height => '400');
    my $w_ok = $w->Button(-text => 'OK', -width => 8, -command => ['destroy', $w]);
    $w_msg->pack(-side => 'top', -fill => 'both');
    $c->pack(-side => 'top', -expand => 'yes', -fill => 'both');
    $w_ok->pack(-side => 'bottom', -pady => '5', -anchor => 'center');

    $font = '-Adobe-helvetica-medium-r-normal--*-240-*-*-*-*-*-*';

    $c->create(qw(rectangle 245 195 255 205 -outline black -fill red));

    # First, create the text item and give it bindings so it can be edited.

    $c->addtag('text', 'withtag', $c->create('text', 250, 200, -text => 'This is just a string of text to demonstrate the ' .
					     'text facilities of canvas widgets. You can point, click, and type.  You can ' .
					     'also select and then delete with Control-d.', -width => 440, -anchor => 'n',
					     -font => $font, -justify => 'left'));
    $c->bind('text', '<1>' => sub {textB1Press(@_)});
    $c->bind('text', '<B1-Motion>' => sub {textB1Move(@_)});
    $c->bind('text', '<Shift-1>' => sub {
	my($c) = @_;
        my $e = $c->XEvent;
	my($x, $y) = ($e->x, $e->y);
	$c->select('adjust', 'current', "\@$x,$y");
    });
    $c->bind('text', '<Shift-B1-Motion>' => sub {textB1Move(@_)});
    $c->bind('text', '<KeyPress>' => sub {
	my($c) = @_;
        my $e = $c->XEvent;
	my $A = $e->A;
	$c->insert('text', 'insert', "$A");
    });
    $c->bind('text', '<Shift-KeyPress>' => sub {
	my($c) = @_;
        my $e = $c->XEvent;
	my $A = $e->A;
	$c->insert('text', 'insert', "$A");
    });
    $c->bind('text', '<Return>' => sub {
	my($c) = @_;
        my $e = $c->XEvent;
	$c->insert('text', 'insert', "\\n");
    });
    $c->bind('text', '<Control-h>' => sub {textBs(@_)});
    $c->bind('text', '<Delete>' => sub {textBs(@_)});
    $c->bind('text', '<Control-d>' => sub {
	my($c, $e) = @_;
        my $e = $c->XEvent;
	$c->dchars('text', 'sel.first', 'sel.last');
    });
    $c->bind('text', '<Control-v>' => sub {
	my($c, $e) = @_;
        my $e = $c->XEvent;
	$c->insert('text', 'insert', Tk::selection('get'));
    });

    # Next, create some items that allow the text's anchor position to be edited.

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
    my $item = $c->create('rectangle', $x+40, $y+40, $x+50, $y+50, -outline => 'black', -fill => 'red');
    $c->bind($item, '<1>' => sub {
	my($c, $e) = @_;
        my $e = $c->XEvent;
	$c->itemconfigure('text', -anchor => 'center');
    });
    $c->create('text', $x+45, $y-5, -text => 'Text Position', -anchor => 's',
	       -font => '-Adobe-times-medium-r-normal--*-240-*-*-*-*-*-*', -fill => 'brown');

    # Lastly, create some items that allow the text's justification to be changed.

    $x = 350; $y = 50; $color = 'SeaGreen2';
    mkTextConfig $c, $x,    $y,    -justify => 'left',   $color;
    mkTextConfig $c, $x+30, $y,    -justify => 'center', $color;
    mkTextConfig $c, $x+60, $y,    -justify => 'right',  $color;
    $c->create('text', $x+45, $y-5, -text => 'Justification', -anchor => 's',
	       -font => '-Adobe-times-medium-r-normal--*-240-*-*-*-*-*-*', -fill => 'brown');

    $c->bind('config', '<Enter>' =>  sub {textEnter(@_)});
    $c->bind('config', '<Leave>' => sub {
	my($c, $e) = @_;
        my $e = $c->XEvent;
	$c->itemconfigure('current', -fill => $mkCanvText::textConfigFill);
    });

} # end mkCanvText


sub mkTextConfig {

    my($w, $x, $y, $option, $value, $color) = @_;

    my $item = $w->create('rectangle', $x, $y, $x+30, $y+30, -outline => 'black', -fill => $color, -width => 1);
    $w->bind($item, '<1>', [sub {
	my($w, $option, $value, $e) = @_;
        my $e = $w->XEvent;

	$w->itemconfigure('text', $option => $value);
    }, $option, $value]);
    $w->addtag('config', 'withtag', $item);

} # end mkTextConfig

$mkCanvText::textConfigFill = 'purple';

sub textEnter {

    my($w) = @_;
    my $e = $w->XEvent;

    $mkCanvText::textConfigFill =  ($w->itemconfigure('current', -fill))[4];
    $w->itemconfigure('current', -fill => 'black');

} # end textEnter


sub textB1Press {

    my($w) = @_;
    my $e = $w->XEvent;

    my($x, $y) = ($e->x, $e->y);
    $w->icursor('current', "\@$x,$y");
    $w->focus('current');
    $w->Tk::focus;
    $w->select('from', 'current', "\@$x,$y");

} # end textB1Press


sub textB1Move {

    my($w) = @_;
    my $e = $w->XEvent;

    my($x, $y) = ($e->x, $e->y);
    $w->select('to', 'current', "\@$x,$y");

} # end textB1Move


sub textBs {

    my($w) = @_;
    my $w = $c->XEvent;

    my $char = $w->index('text', 'insert') - 1;
    $w->dchar('text', $char) if $char >= 0;

} # end textBs


1;


