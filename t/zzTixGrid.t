BEGIN { $|=1; $^W=1; }
use strict;
use Test;
use Tk;
use Tk::TixGrid;

BEGIN { plan tests => 6 };

my $mw = Tk::MainWindow->new;

my $tixgrid;
{
   eval { $tixgrid = $mw->TixGrid(); };
   ok($@ eq "");
   ok( Tk::Exists($tixgrid) );
   eval { $tixgrid->pack; };
   ok($@ eq "");
}
##
## TixGrid->nearest gives always a 'TCL panic' if tixgrid is visible in Tk800.003
##
## ptksh> p $tg->nearest(10,10)
## No results
## Tcl_Panic at (eval 7) line 1.
##
{
    my @entry;
    eval { @entry = $tixgrid->nearest(10,10); };  # there should be no entry
    ok($@ eq "");
    ok(
	scalar(@entry),
	0,
        "nearest returned array of size " . @entry . " instead of 0. " .
    	join('|','@entry=', @entry,'')
    );

    ## Make widget visible, nearest -> SEGV
    $tixgrid->update;
    eval { @entry = $tixgrid->nearest(10,10); };  # there should be no entry
    ok($@ eq "");

}


__END__
