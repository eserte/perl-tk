package main;

unshift(@INC, "../..");

use Tk;
use English;
use Carp;

require Tk::Frame;
require Tk::Balloon;

print "1..1 ";
$lmsg = "";

$top = MainWindow->new;
$f = $top->Frame;

# status bar widget
$status = $top->Label(-width => 40, -relief => "sunken", -bd => 1);
$status->pack(-side => "bottom", -fill => "y", -padx => 2, -pady => 1);

# create the widgets to be explained
$b1 = $top->Button(-text => "Something Unexpected",
		   -command => sub { $top->destroy;});
$b2 = $top->Button(-text => "Something Else Unexpected");
$b2->configure(-command => sub {$b2->destroy;});

$b1->pack(-side => "top", -expand => 1);
$b2->pack(-side => "top", -expand => 1);

# create the balloon widget
$b = $top->Balloon(-statusbar => $status);

$b->attach($b1,
	   -balloonmsg => "Close Window",
	   -statusmsg => "Press this button to close this window");
$b->attach($b2,
	   -balloonmsg => "Self-destruct\nButton",
	   -statusmsg => "Press this button and it will get rid of itself");

MainLoop;

print "ok 1\n";
