BEGIN
  {
    $| = 1;
    $^W = 1;

    eval { require Test; };
    if ($@)
      {
	print "1..0\n";
	print STDERR "Test.pm module not installed. ";
	exit;
      }
    Test->import;
  }
use strict;
##
## Almost all widget classes:  load module, create, pack, and
## destory an instance.
##
## Menu stuff not tested up to now
##

use vars '@class';

BEGIN 
  {
    @class = (
	# Tk core widgets
	qw(
		Button
		Canvas
		Checkbutton
		Entry
		Frame
		Label
		Listbox
		Radiobutton
		Scale
		Scrollbar
		Text
		Toplevel
	),
	# Tix core widgets
	qw(
		HList
		InputO
		NoteBook
		TList
		TixGrid
		Optionmenu
	),
	# Tixish composites
	qw(
		BrowseEntry
		Tree
		DirTree
	),
	# perl/Tk composites
	qw(
		LabEntry
		LabFrame
		ColorEditor
		Optionmenu
		ROText
		Table
		Tiler
		TextUndo

		Dialog
		DialogBox
		FileSelect
		
	)
   );

   @class = grep(!/InputO/,@class) if ($^O eq 'MSWin32');

   plan test => (8*@class+3);

  };

eval { require Tk; };
ok($@, "", "loading Tk module");

my $mw;
eval {$mw = Tk::MainWindow->new();};
ok($@, "", "can't create MainWindow");
ok(Tk::Exists($mw), 1, "MainWindow creation failed");

my $w;
foreach my $class (@class)
  {
    undef($w);

    eval "require Tk::$class;";
    ok($@, "", "Error loading Tk::$class");

    eval { $w = $mw->$class(); };
    ok($@, "", "can't create $class widget");
    skip($@, Tk::Exists($w), 1, "$class instance does not exist");

    if (Tk::Exists($w))
      {
        if ($w->isa('Tk::Wm'))
          {
	    # KDE-beta4 wm with policies:
	    #     'interactive placement'
	    #		 okay with geometry and positionfrom
	    #     'manual placement'
	    #		geometry and positionfrom do not help
	    eval { $w->positionfrom('user'); };
            #eval { $w->geometry('+10+10'); };
	    ok ($@, "", 'Problem set postitionform to user');

            eval { $w->Popup; };
	    ok ($@, "", "Can't Popup a $class widget")
          }
        else
          {
	    ok(1); # dummy for above positionfrom test
            eval { $w->pack; };
	    ok ($@, "", "Can't pack a $class widget")
          }
        eval { $mw->update; };
        ok ($@, "", "Error during 'update' for $class widget");

        eval { $w->destroy; };
        ok($@, "", "can't destroy $class widget");
        ok(!Tk::Exists($w), 1, "$class: widget not really destroyed");
      }
    else
      { 
        # Widget $class couldn't be created:
	#	Popup/pack, update, destroy skipped
	for (1..5) { skip (1,1,1, "skipped because widget could not be created"); }
      }
  }

1;
__END__
