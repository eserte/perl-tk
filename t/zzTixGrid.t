BEGIN { $|=1; $^W=1; }
use strict;
use Test;
use Tk;

BEGIN { plan tests => 7 };

my $mw = Tk::MainWindow->new;

my $tixgrid;
{
   eval { require Tk::TixGrid; };
   ok($@, "", 'Problem loading Tk::TixGrid');
   eval { $tixgrid = $mw->TixGrid(); };
   ok($@, "", 'Problem creating TixGrid widget');
   ok( Tk::Exists($tixgrid) );
   eval { $tixgrid->grid; };
   ok($@, "", '\$tixgrid->grid problem');
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
