# -*- perl -*-
BEGIN { $^W = 1; $| = 1; }

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

plan tests => 1;
my $m = Tk::MainWindow->new;
$m->bind('all','<Enter>',\&cb_enter);
$m->update;
$m->eventGenerate('<Motion>',qw/-x 10 -y 10 -warp 1/);
my $finished = 0;
while (! $finished){
    $m->update;
}
sub cb_enter{
    my $w = $_[0]->XEvent->Info('W') ;
    is($w, $m, 'XEvent::Info(W) returns correct window reference');
    $finished ++;
}
