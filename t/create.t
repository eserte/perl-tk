use strict;
BEGIN { $^W = 1 };
use Test;
##
## Almost all 'normal' all widget loaded:  load module, create, pack, and
## destory an instance.
##
## Dialog and Menu stuff not tested here
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
		TextUndo

		Dialog
		DialogBox
		FileSelect
		
	)
   );

   plan test => (7*@class+3);

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
            eval { $w->Popup; };
	    ok ($@, "", "Can't Popup a $class widget")
          }
        else
          {
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
	skip (1);
	skip (1);
	skip (1);
	skip (1);
      }
  }

1;
__END__
