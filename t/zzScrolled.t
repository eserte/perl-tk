# -*- perl -*-
BEGIN { $|=1; $^W=1; }
use strict;
use Test;
use Tk;

BEGIN { plan tests => 94};

my $mw = Tk::MainWindow->new;
eval { $mw->geometry('+10+10'); };  # This works for mwm and interactivePlacement

my $scrl;
my $text;
{
   eval { require Tk::Text; };
   ok($@, "", "Problem loading Tk::Text");
   eval { $scrl = $mw->Scrolled('Text', -scrollbars=>'sw', -setgrid=>1); };
   ok($@, "", "Problem creating Scrolled('Text')");
   ok( Tk::Exists($scrl) );
   eval { $scrl->grid; };
   ok($@, "", 'Problem managing Scrolled Text with grid');
   eval { $scrl->update; };
   ok($@, "", 'Problem with update');
   eval { $text = $scrl->Subwidget('text'); };
   ok($@, "", 'Problem get subwidget text');
}
##
## -fg/-foreground was not propagated to Text widget until
## and including Tk800.003
##
{
    my ($oldcol, $txtcol);
    my $newcol = 'yellow';

    for my $opt ( qw(-fg -foreground -bg -background) )
      {
        eval { $oldcol = $scrl->cget($opt); };
        ok($@, "", "cget $opt");

        ok( $oldcol ne $newcol, 1, "Ooops, colors are already the same $oldcol=$newcol");

	## Set
        eval { $scrl->configure($opt=>$newcol); };
        ok($@, "", "configure $opt => $newcol");
        eval { $txtcol = $text->cget($opt); };
        ok($@, "", "text cget $opt");
        ok($txtcol, $newcol, "$opt not propagated to Text subwidget");
        $mw->update;

	## ReSet
        eval { $scrl->configure($opt=>$oldcol); };
        ok($@, "", "Reset: configure $opt => $oldcol");
        eval { $txtcol = $scrl->cget($opt); };
        ok($@, "", "Reset: text cget $opt");
        ok($txtcol, $oldcol, "Reset scrolled $opt color");
        $mw->update;
      }
}
##
## Scrolled suppress size changes up to and including at least Tk800.003
## and including Tk800.004.  config/cget are okay but geometry uncovers it.
##
{
    my ($oldsize, $newsize, $oldgeo, $newgeo);

    for my $opt (qw(-height -width))
      {
        for my $chg (qw(-5 5))
          {
            eval { $oldsize = $scrl->cget($opt); };
            ok($@, "", "Sizechk: cget $opt");
            eval { $oldgeo  = $scrl->geometry; };
            ok($@, "", "Sizechk: geometry $opt");

	    ## Set
            eval { $scrl->configure($opt=>($oldsize+$chg)); };
            ok($@, "", "configure $opt => $oldsize + $chg");
            eval { $mw->update; };
            ok($@, "", "Sizechg: Error update configure $opt");
            eval { $newsize = $text->cget($opt); };
            ok($@, "", "Sizechg: cget $opt");
            ok($newsize, $oldsize+$chg, "No size change.");

	    # check if geometry has changed
            eval { $newgeo  = $scrl->geometry; };
            ok($@, "", "Sizechk: new geometry $opt");
            ok($newgeo, $oldgeo, "Sizechk: Ooops, geometry has changed " .
		"($newgeo) for $opt => $oldsize+($chg)"
		);

	    ## ReSet
            eval { $scrl->configure($opt=>$oldsize); };
            ok($@, "", "Reset size: configure $opt => $oldsize");
            eval { $newsize = $text->cget($opt); };
            ok($@, "", "Reset size: text cget $opt");
            ok($newsize, $oldsize, "Reset size: scrolled $opt ");
            eval { $mw->update; };
            ok($@, "", "Sizechg: Error reset update configure $opt");
            eval { $newgeo  = $scrl->geometry; };
            ok($@, "", "Sizechk: reset geometry $opt");
            ok($newgeo, $oldgeo, "Sizechk: geometry has not changed not reset" .
		"for $opt => $oldsize+($chg)"
		);
          }
      }
}

1;
__END__
