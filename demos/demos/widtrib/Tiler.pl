#Tiler, arrange widgets in rows
use strict;
use Tk;
use Tk::Tiler;

my $mw = MainWindow->new();
my $ti = (@ARGV ? $mw->Scrolled('Tiler') : $mw->ScrlTiler);
my $num = $ti->cget('-rows') * $ti->cget('-columns');
$mw->Label(-text=>"Tiler with $num widgets")->pack;
foreach (1 .. $num)
  {
    $ti->Manage( $ti->Label(-text=>"**$_**") );
  }
$ti->pack(-expand=>'yes',-fill=>'both');# tiler has to contain something
                                        # before packing (Tk800.004)
MainLoop;

