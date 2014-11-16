# -*- perl -*-
BEGIN { $|=1; $^W=1; }
use strict;
use Test::More;
BEGIN {
    # Test::More::note not available in older Test::More
    if (!defined &note) {
	*note = sub { diag @_ };
    }
}
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
		Frame
		Toplevel

		Label
		Button
		Checkbutton
		Radiobutton

		Entry
		Spinbox

		Listbox

		Scale
		Scrollbar

		Labelframe
		Panedwindow

		Canvas
		Text
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
	($^O eq 'MSWin32') ? () : qw(ColorEditor),
	qw(
		LabEntry
		LabFrame
		Optionmenu
		ROText
		Table
		Tiler
		TextUndo
		TextEdit
		Dialog
		DialogBox
		FileSelect
	),
	# Tclish composites
	qw(
		FBox
		IconList
	),
   );

   require Tk if ($^O eq 'cygwin');
   @class = grep(!/InputO/,@class) if ($^O eq 'MSWin32' or
			    ($^O eq 'cygwin' and defined($Tk::platform)
					     and $Tk::platform eq 'MSWin32'));

   plan tests => (15*@class+4);

  };

if (!defined &diag)
 {
  *diag = sub { print "# $_[0]\n" };
 }

eval { require Tk; };
is($@, "", "loading Tk module");

my $mw;
eval {$mw = Tk::MainWindow->new();};
is($@, "", "No error while creating MainWindow");
ok(Tk::Exists($mw), "MainWindow creation OK");
eval { $mw->geometry('+10+10'); };  # This works for mwm and interactivePlacement

eval { Tk::MainWindow::Create() };
isnt($@, '', "no segfault for Tk::MainWindow::Create without args, but an error message");

my $w;
foreach my $class (@class)
  {
    note "Testing $class";
    undef($w);

    eval "require Tk::$class;";
    is($@, "", "No error loading Tk::$class");
 SKIP: {
	skip "Test::More too old for isa_ok class check", 1
	    if $Test::More::VERSION < 0.88;
	isa_ok("Tk::$class", 'Tk::Widget');
    }

    eval { $w = $mw->$class(); };
    is($@, "", "Can create $class widget");
    ok(Tk::Exists($w), "$class instance exists");

 SKIP: {
        skip "Window cannot be created", 6
	  if !Tk::Exists($w);

        is($w->class,$class,"Window class matches");

        if ($w->isa('Tk::Wm'))
          {
	    # KDE-beta4 wm with policies:
	    #     'interactive placement'
	    #		 okay with geometry and positionfrom
	    #     'manual placement'
	    #		geometry and positionfrom do not help
	    eval { $w->positionfrom('user'); };
            #eval { $w->geometry('+10+10'); };
	    is ($@, "", 'No problem set postitionform to user');

            eval { $w->Popup; };
	    is ($@, "", "Can Popup a $class widget")
          }
        else
          {
	    pass("dummy for positionfrom test for non-Wm widgets");
            eval { $w->pack; };
	    is ($@, "", "Can pack a $class widget")
          }
        note "$class update";
        eval { $mw->update; };
        is ($@, "", "No error during 'update' for $class widget");

        my @dummy;
        note "$class configure list";
        eval { @dummy = $w->configure; };
        is ($@, "", "No error while getting configure as list for $class");
        my $dummy;
        note "$class configure scalar";
        eval { $dummy = $w->configure; };
        is ($@, "", "No error while getting configure as scalar for $class");
        is (scalar(@dummy),scalar(@$dummy), "Error: scalar config != list config");

        $@ = "";
        my %skip = (-class => 1);
        foreach my $opt ($w->CreateOptions)
         {
          $skip{$opt} = 1;
         }
        foreach my $opt (@dummy)
         {
          my @val = @$opt;
          if (@val != 2 && !exists($skip{$val[0]}) )
           {
            eval { $w->configure($val[0],$val[-1]) };
            if ($@)
             {
              diag "$class @val:$@";
              last;
             }
           }
         }
        is($@,"","Re-configure $class");

        note "$class update post-configure";
        eval { $mw->update; };
        is ($@, "", "'update' after configure for $class widget");

        note "$class destroy";
        eval { $w->destroy; };
        is($@, "", "can destroy $class widget");
        ok(!Tk::Exists($w), "$class: widget is really destroyed");

        # XXX: destroy-destroy test disabled because nobody vote for this feature
	# Nick Ing-Simmmons wrote:
	# The only way to make test pass, is when Tk800 would fail, to specifcally look
	# and see if method is 'destroy', and ignore it. Can be done but is it worth it?
	# Note I cannot call tk's internal destroy as I have no way of relating
	# (now destroy has happened) the object back to interp/MainWindow that it used
	# to be associated with, and hence cannot create the args I need to pass
	# to the core.

        # since Tk8.0 a destroy on an already destroyed widget should
        # not complain
        #eval { $w->destroy; };
        #ok($@, "", "Ooops, destroying a destroyed widget should not complain");

      }
  }

1;
__END__
