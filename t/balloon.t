# -*- perl -*-
BEGIN { $|=1; $^W=1; }
use strict;
use Test;
use Tk;

BEGIN { plan tests => 8 };

my $mw = Tk::MainWindow->new;
eval { $mw->geometry('+10+10'); };  # This works for mwm and interactivePlacement

my $statusbar = $mw->Label->pack;

my $balloon;
eval { require Tk::Balloon; };
ok($@, "", 'Problem loading Tk::Balloon');
eval { $balloon = $mw->Balloon; };
ok($@, "", 'Problem creating Balloon widget');
ok( Tk::Exists($balloon) );

my $l = $mw->Label->pack;
eval { $balloon->attach($l, -msg => "test"); };
ok($@, "", 'Problem attaching message to Label widget');
eval { $balloon->attach($l, -statusmsg => "test1", -balloonmsg => "test2"); };
ok($@, "", 'Problem attaching statusmsg/baloonmsg to Label widget');

my $c = $mw->Canvas->pack;
my $ci = $c->createLine(0,0,10,10);
eval { $balloon->attach($c, -msg => {$ci => "test"}); };
ok($@, "", 'Problem attaching message to Canvas item');

my $menubar = $mw->Menu;
$mw->configure(-menu => $menubar);
my $filemenu = $menubar->cascade(-label => "~File", -tearoff => 0);
$filemenu->command(-label => "Test1");
$filemenu->command(-label => "Test2");
$filemenu->command(-label => "Test3");
my $filemenu_menu = $filemenu->cget(-menu);

eval { $balloon->attach($filemenu_menu,
			-msg => ["Test1 msg", "Test2 msg", "Test3 msg"]); };
ok($@, "", 'Problem attaching message to Menu');

eval { $balloon->configure(-motioncommand => \&motioncmd); };
ok($@, "", "Can't set motioncommand option");

## not yet:
#  $l->eventGenerate("<Motion>");
#  sub motioncmd {
#      my(@args) = @_;
#      warn "<<<@args";
#  }

1;
__END__
