#labframe, frame with embedded label

use Tk;
use English;
use Carp;

require Tk::LabFrame;
require Tk::LabEntry;

my $test = 'Test this';

outer:
{
    my $top = MainWindow->new;
    my $f = $top->LabFrame(-label => "This is a label", -labelside => "acrosstop");
    $f->LabEntry(-label => "Testing", -textvariable => \$test)->pack;
    $f->pack;
    MainLoop;
}
