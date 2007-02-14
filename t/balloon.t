# -*- perl -*-
use strict;
use Tk;

BEGIN {
    if (!eval q{
	use Test::More;
	1;
    }) {
	print "1..0 # skip: no Test::More module\n";
	exit;
    }
}

plan tests => 10;

my $mw = Tk::MainWindow->new;
eval { $mw->geometry('+10+10'); };  # This works for mwm and interactivePlacement

my $statusbar = $mw->Label->pack;

my $balloon;
eval { require Tk::Balloon; };
is($@, "", 'Loading Tk::Balloon');
eval { $balloon = $mw->Balloon; };
is($@, "", 'Creating Balloon widget');
ok( Tk::Exists($balloon), "Existance of ballon" );

my $l = $mw->Label->pack;
eval { $balloon->attach($l, -msg => "test"); };
is($@, "", 'Attaching message to Label widget');
eval { $balloon->attach($l, -statusmsg => "test1", -balloonmsg => "test2"); };
is($@, "", 'Attaching statusmsg/baloonmsg to Label widget');

my $c = $mw->Canvas->pack;
my $ci = $c->createLine(0,0,10,10);
eval { $balloon->attach($c, -msg => {$ci => "test"}); };
is($@, "", 'Attaching message to Canvas item');

my $menubar = $mw->Menu;
$mw->configure(-menu => $menubar);
my $filemenu = $menubar->cascade(-label => "~File", -tearoff => 0);
$filemenu->command(-label => "Test1");
$filemenu->command(-label => "Test2");
$filemenu->command(-label => "Test3");
my $filemenu_menu = $filemenu->cget(-menu);

eval { $balloon->attach($filemenu_menu,
			-msg => ["Test1 msg", "Test2 msg", "Test3 msg"]); };
is($@, "", 'Attaching message to Menu');

eval { $balloon->configure(-motioncommand => \&motioncmd); };
is($@, "", "Set motioncommand option");

my $lb = $mw->Listbox->pack;
$lb->insert("end",1,2,3,4);
eval { $balloon->attach($lb, -msg => ['one','two','three','four']); };
is($@, "", 'Attaching message to Listbox items');

my $slb = $mw->Scrolled('Listbox')->pack;
$lb->insert("end",1,2,3,4);
eval { $balloon->attach($slb->Subwidget('scrolled'),
			-msg => ['one','two','three','four']); };
is($@, "", 'Attaching message to scrolled Listbox items');

## not yet:
#  $l->eventGenerate("<Motion>");
#  sub motioncmd {
#      my(@args) = @_;
#      warn "<<<@args";
#  }

1;
__END__
