# Learn how to write your own widget demonstration.

use vars qw/$TOP/;

sub TEMPLATE {
    my($demo) = @_;
    $TOP = $MW->WidgetDemo(
        -name             => $demo,
        -text             => 'Learn how to write a widget demonstration!',
	-geometry_manager => 'grid',
        -title            => 'WidgetDemo Example',
        -iconname         => 'WidgetDemo',
    );
    $TOP->Label(-text => 'Click "See Code".')->grid;
}
__END__

The template code above specifies how user contributed widget demonstrations
must be written.  

All demonstrations must be a unique subroutine, in a directory of your
choosing, stored in a file with the same name as the subroutine suffixed with
".pl".  So file TEMPLATE.pl contains subroutine TEMPLATE().

widget looks in the directory specified on the command line to load user
contributed demonstrations.  If no directory name is specified when widget is
invoked and the environment variable WIDTRIB is defined then demonstrations
are loaded from the WIDTRIB directory. If WIDTRIB is undefined then widget
defaults to the released user contributed directory.

The first line of the file is the DDD (Demonstration Description Data), which
briefly describes the purpose of the demonstration.  The widget program reads
this line and uses it when building its interface.

For consistency your demonstration should use the WidgetDemo widget.  This is  
a toplevel widget with three frames. The top frame contains descriptive
demonstration text.  The bottom frame contains the "Dismiss" and "See Code"
buttons.  The middle frame is the demonstration container, which can be
managed by either the pack or grid geometry manager.

When widget calls your subroutine it's passed one argument, the demonstration
name.  Since your subroutine can "see" all of widget's global variables, you 
use $MW (the main window reference) to create the WidgetDemo toplevel; be sure
to pass at least the -name and -text parameters.  -geometry_manager defaults
to "pack".  The call to WidgetDemo() returns a reference to the containing
frame for your demonstration, so treat it as if it were the MainWindow, the
top-most window of your widget hierarchy.

Other consideration:

    . widget global variables are all uppercase, like $MW - be careful not
      to stomp on them!

    . If your demonstration has a Quit button change it to ring the bell
      and use the builtin Dismiss instead.

    . Remove a MainLoop() call, if present.

    . Be sure $TOP is declared in a "use vars" statement and not as a
      lexical my() in the subroutine (see below).

    . If you're wrapping an existing main program in a subroutine be very
      alert for closure bugs.  Lexicals inside a subroutine become closed
      so you may run into initialization problems on the second and
      subsequent invokations of the demonstration.  The npuz and plop
      demonstrations show how to work around this.  Essentially, remove
      all "global" my() variables and place them within a "use vars".
      This practice is prone to subtle bugs and is not recommended!
