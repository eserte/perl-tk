# Ballon, pop up help window when mouse lingers over widget.

use Tk;
use English;
use Carp;

use Tk::Frame;
use Tk::Balloon;

my $lmsg = "";

my $top = MainWindow->new;
my $f = $top->Frame;

# status bar widget
my $status = $top->Label(-width => 40, -relief => "sunken", -bd => 1);
$status->pack(-side => "bottom", -fill => "y", -padx => 2, -pady => 1);

# create the widgets to be explained
my $b1 = $top->Button(-text => "Something Unexpected",
		      -command => sub {$top->destroy;});
my $b2 = $top->Button(-text => "Something Else Unexpected");
$b2->configure(-command => sub {$b2->destroy;});

$b1->pack(-side => "top", -expand => 1);
$b2->pack(-side => "top", -expand => 1);

$top->Text(-height => 5)->pack->insert('end',<<END);

Move the mouse cursor over the buttons above and let it linger.
A message will be displayed in status box below and a descriptive
balloon will appear.

END

# create the balloon widget
my $b = $top->Balloon(-statusbar => $status);

$b->attach($b1,
	   -balloonmsg => "Close Window",
	   -statusmsg => "Press this button to close this window");
$b->attach($b2,
	   -balloonmsg => "Self-destruct\nButton",
	   -statusmsg => "Press this button and it will get rid of itself");

MainLoop;


