# Dialog - a translation of `tk_dialog' from Tcl/Tk to TkPerl (based on
# John Stoffel's idea).
#
# Stephen O. Lidie, Lehigh University Computing Center.  94/12/27
# lusol@Lehigh.EDU
#
# This is an OO implementation of `tk_dialog'.  First, create all your Dialog
# objects during program initialization.  When it's time to use a dialog, 
# invoke the `show' method on a dialog object; the method then displays the 
# dialog, waits for a button to be invoked, and returns the text label of the 
# selected button.
#


use vars qw($VERSION);
$VERSION = '2.000'; # $Id: //depot/Tk/Tk/Dialog.pm#9$

# A Dialog object essentially consists of two subwidgets: a Label widget for
# the bitmap and a Label wigdet for the text of the dialog.  If required, you 
# can invoke the `configure' method to change any characteristic of these 
# subwidgets.
#
# Because a Dialog object is a Toplevel widget all the 'composite' base class
# methods are available to you.
#
# Advertised widgets:  bitmap, message.
#
# 1) Call the constructor to create the dialog object, which in turn returns 
#    a blessed reference to the new composite widget:
#
#    require Tk::Dialog;
#
#    $DialogRef = $mw->Dialog(
#        -title          => $title,
#        -text           => $text,
#        -bitmap         => $bitmap,
#        -default_button => $default_button,
#        -buttons        => [@button_labels],
#    );
#
#       mw             - a window reference, usually the result of a
#                        MainWindow->new call.
#       title          - Title to display in the dialog's decorative frame.
#       text           - Message to display in the dialog widget.
#       bitmap         - Bitmap to display in the dialog.
#       default_button - Text label of the button that is to display the
#                        default ring (''signifies no default button).
#       button_labels  - A reference to a list of one or more strings to
#                        display in buttons across the bottom of the dialog.
#
# 2) Invoke the `show' method on a dialog object:
#
#    $button_label = $DialogRef->Show;
#
#       This returns the text label of the selected button.
#
#    (Note:  you can request a global grab by passing the string "-global"
#    to the `show' method.)

package Tk::Dialog;
use Carp;
use strict qw(vars);
require Tk::Toplevel;
@Tk::Dialog::ISA = qw(Tk::Toplevel);

use vars qw($VERSION);
$VERSION = '2.009'; # $Id: //depot/Tk/Tk/Dialog.pm#9$



Construct Tk::Widget 'Dialog';


sub Populate
{

    # Dialog object constructor.  Uses `new' method from base class
    # to create object container then creates the dialog toplevel.

    my($cw, $args) = @_;

    $cw->SUPER::Populate($args);

    my ($w_bitmap,$w_but,$pad1,$pad2);

    my $buttons = delete $args->{'-buttons'};
    $buttons = ['OK'] unless (defined $buttons);
    my $default_button = delete $args->{-default_button};
    $default_button =  $buttons->[0] unless (defined $default_button);

    
    # Create the Toplevel window and divide it into top and bottom parts.

    $cw->{'selected_button'} = '';
    my (@pl) = (-side => 'top', -fill => 'both');
    ($pad1, $pad2) =
        ([-padx => '3m', -pady => '3m'], [-padx => '3m', -pady => '2m']);

    $cw->withdraw;
    $cw->iconname('Dialog');
    $cw->protocol('WM_DELETE_WINDOW' => sub {});
    $cw->transient($cw->Parent->toplevel);

    my $w_top = $cw->Frame(Name => 'top',-relief => 'raised', -borderwidth => 1);
    my $w_bot = $cw->Frame(Name => 'bot',-relief => 'raised', -borderwidth => 1);
    $w_top->pack(@pl);
    $w_bot->pack(@pl);

    # Fill the top part with the bitmap and message.

    @pl = (-side => 'left');

    $w_bitmap = $w_top->Label(Name => 'bitmap');
    $w_bitmap->pack(@pl, @$pad1);

    my $w_msg = $w_top->Label( -wraplength => '3i', -justify    => 'left' );

    $w_msg->pack(-side => 'right', -expand => 1, -fill => 'both', @$pad1);

    # Create a row of buttons at the bottom of the dialog.

    my($w_default_button, $bl) = (undef, '');
    foreach $bl (@$buttons) {
        $w_but = $w_bot->Button(
            -text => $bl,
            -command => [
                sub {
                    $_[0]->{'selected_button'} = $_[1];
                }, $cw, $bl,
            ]
        );
        if ($bl eq $default_button) {
            $w_default_button = $w_bot->Frame(
                -relief      => 'sunken',
                -borderwidth => 1
            );
            $w_but->raise($w_default_button);
            $w_default_button->pack(@pl, -expand => 1, @$pad2);
            $w_but->pack(-in => $w_default_button, -padx => '2m',
                         -pady => '2m');
            $cw->bind(
                '<Return>' => [
                    sub {
                        $_[1]->flash; 
                        $_[2]->{'selected_button'} = $_[3];
                    }, $w_but, $cw, $bl,
                ]
            );
        } else {
         $w_but->pack(@pl, -expand => 1, @$pad2);
        }
    } # forend all buttons

    $cw->Advertise(message => $w_msg);
    $cw->Advertise(bitmap  => $w_bitmap );
    $cw->{'default_button'} = $w_default_button;

    $cw->ConfigSpecs(
                      -image      => ['bitmap',undef,undef,undef],
                      -bitmap     => ['bitmap',undef,undef,undef],
                      -fg         => ['ADVERTISED','foreground','Foreground','black'],
                      -foreground => ['ADVERTISED','foreground','Foreground','black'],
                      -bg         => ['DESCENDANTS','background','Background',undef],
                      -background => ['DESCENDANTS','background','Background',undef],
                      -font       => ['message','font','Font', '-*-Times-Medium-R-Normal--*-180-*-*-*-*-*-*'],
                      DEFAULT     => ['message',undef,undef,undef]
                     );
} # end Dialog constructor

sub Show {

    # Dialog object public method - display the dialog.

    my ($cw, $grab_type) = @_;

    croak "Dialog:  `show' method requires at least 1 argument"
        if scalar @_ < 1 ;

    my $old_focus = $cw->focusSave;
    my $old_grab  = $cw->grabSave;

    # Update all geometry information, center the dialog in the display
    # and deiconify it

    $cw->Popup(); 

    # set a grab and claim the focus.

    if (defined $grab_type && length $grab_type) {
        $cw->grab($grab_type);
    } else {
        $cw->grab;
    }
    $cw->waitVisibility;
    $cw->update;
    if (defined $cw->{'default_button'}) 
     {
      $cw->{'default_button'}->focus;
     } 
    else 
     {
      $cw->focus;
     }

    # Wait for the user to respond, restore the focus and grab, withdraw
    # the dialog and return the label of the selected button.

    $cw->waitVariable(\$cw->{'selected_button'});
    $cw->grabRelease;
    $cw->withdraw;
    &$old_focus;
    &$old_grab;
    return $cw->{'selected_button'};

} # end Dialog show method

1;
