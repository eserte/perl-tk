#!perl
BEGIN
{
 $| = 1;
 print "1..4\n";
}
use Tk;
use Tk::PNG;
print "ok 1\n";
my $mw = MainWindow->new;
$mw->geometry('+10+10');
my $img = $mw->Photo(-format => "png", -file => "pngtest.png");
print "not " unless $img;
print "ok 2\n";
my $l = $mw->Label(-image => $img)->pack;
print "not " unless $l;
print "ok 3\n";
$mw->update;
$mw->after(1000,[destroy => $mw]);
MainLoop;
print "ok 4\n";

