package Tk::Dialog;

use vars qw($VERSION);
$VERSION = '3.020'; # $Id: //depot/Tk8/Tk/Dialog.pm#20$

# Dialog - a translation of `tk_dialog' from Tcl/Tk to TkPerl (based on
# John Stoffel's idea).
#
# Stephen O. Lidie, Lehigh University Computing Center.  94/12/27
# lusol@Lehigh.EDU

# Documentation after __END__

use Carp;
use strict;

require Tk::Toplevel;
use base qw(Tk::Toplevel);

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


    $cw->iconname('Dialog');
    $cw->protocol('WM_DELETE_WINDOW' => sub {});
    $cw->transient($cw->Parent->toplevel);
    $cw->withdraw;

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
        if ($Tk::platform eq 'MSWin32') {
            $w_but->configure(-width => 10, -pady => 0); 
        }

        if ($bl eq $default_button) {
            if ($Tk::platform eq 'MSWin32') {
                $w_default_button = $w_but;
                $w_but->configure(-borderwidth => 2);
                $w_but->pack(@pl, -expand => 1, @$pad2);
            } else {
                my $w_default_frame = $w_bot->Frame(
                    -relief      => 'sunken',
                    -borderwidth => 1
                );
                $w_but->raise($w_default_frame);
                $w_default_frame->pack(@pl, -expand => 1, @$pad2);
                $w_but->pack(-in => $w_default_frame, -padx => '2m',
                             -pady => '2m');
            }
            $cw->bind(
                '<Return>' => [
                    sub {
                        $_[1]->flash; 
                        $_[2]->{'selected_button'} = $_[3];
                    }, $w_but, $cw, $bl,
                ]
            );
	    $w_default_button = $w_but;
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
    $cw->Delegates('Construct' => $w_top);
} # end Dialog constructor

sub Show {

    # Dialog object public method - display the dialog.

    my ($cw, $grab_type) = @_;

    croak "Dialog:  `Show' method requires at least 1 argument"
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

} # end Dialog Show method

1;

__END__

=cut

