package main;

unshift(@INC, "../..");

use Tk;
use English;
use Carp;

require Tk::LabFrame;
require Tk::LabEntry;

my $test = 'Test this';

outer:
{
    $top = MainWindow->new;
    my $f = $top->LabFrame(-label => "This is a label", -labelside => "acrosstop");
    $f->LabEntry(-label => "Testing", -textvariable => \$test)->pack;
    $f->pack;
    MainLoop;
}
