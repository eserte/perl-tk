# ErrorDialog - a translation of `tkerror' from Tcl/Tk to TkPerl.
#
# Currently TkPerl background errors are sent to stdout/stderr; use this
# module if you want them in a window.  You can also "roll your own" by 
# supplying the routine Tk::Error.
#
# Stephen O. Lidie, Lehigh University Computing Center.  95/03/02
# lusol@Lehigh.EDU
#
# This is an OO implementation of `tkerror', with a twist:  since there is
# only one ErrorDialog object, you aren't required to invoke the constructor
# to create it; it will be created automatically when the first background
# error occurs.  However, in order to configure the ErrorDialog object you
# must call the constructor and create it manually.
#
# The ErrorDialog object essentially consists of two subwidgets: an
# ErrorDialog widget to display the background error and a Text widget for the
# traceback information.  If required, you can invoke the configure() method
# to change some characteristics of these subwidgets.
#
# Because an ErrorDialog object is a Frame widget all the composite base
# class methods are available to you.
#
# Advertised widgets:  error_dialog, text.
#
# 1) Call the constructor to create the ErrorDialog object, which in turn
#    returns a blessed reference to the new object:
#
#    require Tk::ErrorDialog;
#
#    $ED = $mw->ErrorDialog(
#        -cleanupcode     => $code,
#        -appendtraceback => $bool,
#    );
#
#       mw -   a window reference, usually the result of a MainWindow->new
#              call.
#       code - a CODE reference if special post-background error processing
#              is required (default is undefined).
#       bool - a boolean indicating whether or not to append successive
#              tracebacks (default is 1, do append).
#

package Tk::ErrorDialog;
use English;
use Tk ();
require Tk::Dialog;
@Tk::ErrorDialog::ISA = qw(Tk::Toplevel);

Construct Tk::Widget 'ErrorDialog';

my %options = ( -buttons => ['OK', 'Skip Messages', 'Stack trace'],
                -bitmap  => 'error'
              );
my $ED_OBJECT;

sub import
{
 my $class = shift;
 while (@_)
  {
   my $key = shift;
   my $val = shift;
   $options{$key} = $val;
  }
}

sub Populate {

    # ErrorDialog constructor.  Uses `new' method from base class
    # to create object container then creates the dialog toplevel and the
    # traceback toplevel.

    my($cw, $args) = @ARG;

    my $dr = $cw->Dialog(
        -title          => 'Error in '.$cw->MainWindow->name,
        -text           => 'on-the-fly-text',
        -bitmap         => $options{'-bitmap'},
	-buttons        => $options{'-buttons'},
    );
    $cw->minsize(1, 1);
    $cw->title('Stack Trace for Error');
    $cw->iconname('Stack Trace');
    my $t_ok = $cw->Button(
        -text    => 'OK',
        -command => [
            sub {
		shift->withdraw;
	    }, $cw,
        ]
    );
    my $t_text = $cw->Text(
        -relief  => 'sunken',
        -bd      => 2,
        -setgrid => 'true',
        -width   => 60,
        -height  => 20,
    );
    my $t_scroll = $cw->Scrollbar(
        -relief => 'sunken',
        -command => ['yview', $t_text],
    );
    $t_text->configure(-yscrollcommand => ['set', $t_scroll]);
    $t_ok->pack(-side => 'bottom', -padx => '3m', -pady => '2m');
    $t_scroll->pack(-side => 'right', -fill => 'y');
    $t_text->pack(-side => 'left', -expand => 'yes', -fill => 'both');
    $cw->withdraw;

    $cw->Advertise(error_dialog => $dr); # advertise dialog widget
    $cw->Advertise(text => $t_text);     # advertise text widget
    $cw->ConfigSpecs(-cleanupcode => [PASSIVE, undef, undef, undef],
                     -appendtraceback => [ PASSIVE, undef, undef, 1 ]);
    $ED_OBJECT = $cw;
    return $cw;

} # end new, ErrorDialog constructor


sub Tk::Error {

    # Post a dialog box with the error message and give the user a chance
    # to see a more detailed stack trace.

    my($w, $error, @msgs) = @ARG;

    my $grab = $w->grab('current');
    $grab->Unbusy if (defined $grab);

    $w->ErrorDialog if not defined $ED_OBJECT;

    my($d, $t) = ($ED_OBJECT->Subwidget('error_dialog'), $ED_OBJECT->Subwidget('text'));
    chop $error;
    $d->configure(-text => "Error:  $error");
    $d->bell; 
    my $ans = $d->Show;

    $t->delete('0.0', 'end') if not $ED_OBJECT->{'-appendtraceback'};
    $t->insert('end', "\n");
    $t->mark('set', 'ltb', 'end');
    $t->insert('end', "--- Begin Traceback ---\n$error\n");
    my $msg;
    for $msg (@msgs) {
	$t->insert('end', "$msg\n");
    }
    $t->yview('ltb');

    $ED_OBJECT->deiconify if ($ans =~ /trace/i);

    my $c = $ED_OBJECT->{Configure}{'-cleanupcode'};
    &$c if defined $c;		# execute any cleanup code if it was defined
    $w->break if ($ans =~ /skip/i);

} # end Tk::Error


1;
