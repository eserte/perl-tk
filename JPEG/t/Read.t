#!/usr/local/bin/perl -w
print "1..1\n";
use Tk;
require Tk::JPEG;

my $file = (@ARGV) ? shift : 'jpeg/testimg.jpg';

my $mw = MainWindow->new;
$mw->geometry('+10+10');
my $image = $mw->Photo('-format' => 'jpeg', -file => $file);
$mw->Label(-image => $image)->pack;
$mw->update;
$mw->after(1000,[destroy => $mw]);
MainLoop;
print "ok 1\n";
