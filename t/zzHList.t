# -*- perl -*-
BEGIN { $^W = 1; $| = 1; }

use strict;
use Test;
use Tk;

BEGIN { plan tests => 22 };

my $mw = Tk::MainWindow->new;
eval { $mw->geometry('+10+10'); };  # This works for mwm and interactivePlacement

my $hlist;
{
   eval { require Tk::HList; };
   ok($@, "", 'Problem loading Tk::HList');
   eval { $hlist = $mw->HList(); };
   ok($@, "", 'Problem creating HList widget');
   ok( Tk::Exists($hlist) );
   eval { $hlist->grid; };
   ok($@, "", '$hlist->grid problem');
   eval { $hlist->update; };
   ok($@, "", '$hlist->update problem.');
}
##
## With Tk800.004:
##   1) headerSize returns "x y" instead of [x,y].
##   2) Error headerSize err msg for non existant col contains garbage. E.g.
##	Column "KC@" does not exist at ...
##   3) infoSelection not defined (test is just a bothering reminder to
##      check all other Submethods that should be defined are defined).
##   4) entryconfigure -style contains garbage
##
{
    my $hl = $mw->HList(-header=>1)->grid;
    $hl->headerCreate(0, -text=>'a heading');

    my @dim;
    eval { @dim = $hl->headerSize(0); };
    ok($@, '', "Problems with headerSize method");
    ok(scalar(@dim), 2, 'headerSize returned not a 2 element array: |'.
	join('|',@dim,'')
	);
    eval { $hlist->update; };
    ok($@, "", '$hlist->update problem.');

    eval { $hl->header('size', 1); }; # does not exist
    ok($@ ne "", 1, "Oops, no error for non existent header field");
    ok($@=~m/^Column "1" does not exist/, 1,
	"'$@' does not match /^Column \"1\" does not exist/"
	);
    eval { $hlist->update; };
    ok($@, "", '$hlist->update problem.');

    eval { $hl->info('selection'); };
    ok($@, "", "Problem with info('selection') method.");
    eval { $hl->infoSelection; };
    ok($@, "", "Problem with infoSelection method.");
    eval { $hlist->update; };
    ok($@, "", '$hlist->update problem.');

    $hl->add(1,-text=>'one');
    my $val1 = ( $hl->entryconfigure(1, '-style') )[4];
    # comment out the next line and at least I get always a SEGV
    ok(!defined($val1), 1, "Ooops entryconfigure -style is defined");
    my $val2 = $hl->entrycget(1, '-style');
    ok(!defined($val2), 1, "Ooops entrycget -style is defined");
    # ok($val1, $val2, "entryconfigure and entrycget do not agree");

    my @bbox = $hl->infoBbox(1);
    ok(scalar(@bbox), 4, "\@bbox not 4 items");
    my $bbox = $hl->infoBbox(1);
    ok(ref($bbox), 'ARRAY', "$bbox not an ARRAY");
    foreach my $a (@bbox)
     {
      ok($a, shift(@$bbox), "\$bbox values differ");
     }
    $hl->destroy;
}

1;
__END__

