# $Id: //depot/Tk/Tixish/DialogBox.pm#5$
#
# DialogBox is similar to Dialog except that it allows any widget
# in the top frame. Widgets can be added with the add method. Currently
# there exists no way of deleting a widget once it has been added.

package Tk::DialogBox;

use English;
use Carp;

require Tk::Toplevel;
require Tk::Frame;


use vars qw($VERSION);
$VERSION = '2.005'; # $Id: //depot/Tk/Tixish/DialogBox.pm#5$

@ISA = qw(Tk::Toplevel Tk::Frame);

Tk::Widget->Construct("DialogBox");

sub Populate {
    my ($cw, $args) = @_;

    $cw->SUPER::Populate($args);
    my $buttons = delete $args->{"-buttons"};
    $buttons = ["OK"] unless defined $buttons;
    my $default_button = delete $args->{"-default_button"};
    $default_button = $buttons->[0] unless defined $default_button;

    $cw->{"selected_button"} = '';
    $cw->withdraw;
    $cw->protocol("WM_DELETE_WINDOW" => sub {});
    $cw->transient($cw->toplevel);

    # create the two frames
    my $top = $cw->Component(Frame, "top");
    $top->configure(-relief => "raised", -bd => 1);
    $top->pack(-side => "top", -fill => "both", -ipady => 3, -ipadx => 3);
    my $bot = $cw->Component(Frame, "bottom");
    $bot->configure(-relief => "raised", -bd => 1);
    $bot->pack(-side => "top", -fill => "both", -ipady => 3, -ipadx => 3);

    # create a row of buttons in the bottom.
    foreach $bl (@$buttons) {
	$b = $bot->Button(-text => $bl,
			  -command => [ sub {
			      $_[0]->{"selected_button"} = $_[1];
			  }, $cw, $bl]);
	if ($bl eq $default_button) {
	    $db = $bot->Frame(-relief => "sunken", -bd => 1);
	    $b->raise($db);
	    $b->pack(-in => $db, -padx => "2", -pady => "2");
	    $db->pack(-side => "left", -expand => 1, -padx => 1, -pady => 1);
	    $cw->bind("<Return>" => [ sub {
		$_[2]->flash;
		$_[1]->{"selected_button"} = $_[3];
	    }, $cw, $b, $bl]);
	    $cw->{"default_button"} = $b;
	} else {
	    $b->pack(-side => "left", -expand => 1,  -padx => 1, -pady => 1);
	}
    }
}

sub add {
    my ($cw, $wnam, %args) = @_;
    my $w = $cw->Subwidget("top")->$wnam(%args);
    $cw->Advertise("\L$wnam" => $w);
    return $w;
}

sub Show {
    my ($cw, $grab) = @_;
    croak "DialogBox: `Show' method requires at least 1 argument"
	if scalar @_ < 1;
    my $old_focus = $cw->focusSave;
    my $old_grab = $cw->grabSave;

    $cw->Subwidget("top")->pack;
    $cw->Subwidget("bottom")->pack;

    $cw->Popup();
    if (defined $grab && length $grab && ($grab =~ /global/)) {
	$cw->grabGlobal;
    } else {
	$cw->grab;
    }
    $cw->waitVisibility;
    if (defined $cw->{"default_button"}) {
	$cw->{"default_button"}->focus;
    } else {
	$cw->focus;
    }
    $cw->waitVariable(\$cw->{"selected_button"});
    $cw->grabRelease;
    $cw->withdraw;
    &$old_focus;
    &$old_grab;
    return $cw->{"selected_button"};
}

1;

__END__

=head1 NAME

Tk::DialogBox - create and manipulate a dialog screen.

=head1 SYNOPSIS

    use Tk::DialogBox
    ...
    $d = $top->DialogBox(-title => "Title", -buttons => ["OK", "Cancel"]);
    $w = $d->add(Widget, args);
    ...
    $button = $d->Show;

=head1 DESCRIPTION

B<DialogBox> is very similar to B<Dialog> except that it allows
any widget in the top frame. B<DialogBox> creates two
frames---"top" and "bottom". The bottom frame shows all the
specified buttons, lined up from left to right. The top frame acts
as a container for all other widgets that can be added with the
B<add()> method. The non-standard options recognized by
B<DialogBox> are as follows:

=over 4

=item B<-title>

Specify the title of the dialog box. If this is not set, then the
name of the program is used.

=item B<-buttons>

The buttons to display in the bottom frame. This is a reference to
an array of strings containing the text to put on each
button. There is no default value for this. If you do not specify
any buttons, no buttons will be displayed.

=item B<-default_button>

Specifies the default button that is considered invoked when user
presses <Return> on the dialog box. This button is highlighted. If
no default button is specified, then the first element of the
array whose reference is passed to the B<-buttons> option is used
as the default.

=back

=head1 METHODS

B<DialogBox> supports only two methods as of now:

=over 4

=item B<add(>I<widget>, I<options>B<)>

Add the widget indicated by I<widget>. I<Widget> can be the name
of any Tk widget (standard or contributed). I<Options> are the
options that the widget accepts. The widget is advertized as a
subwidget of B<DialogBox>.

=item B<Show(>I<grab>B<)>

Display the dialog box, until user invokes one of the buttons in
the bottom frame. If the grab type is specified in I<grab>, then
B<Show> uses that grab; otherwise it uses a local grab. Returns
the name of the button invoked.

=back

=head1 BUGS

There is no way of removing a widget once it has been added to the
top frame.

There is no control over the appearance of the buttons in the
bottom frame nor is there any way to control the placement of the
two frames with respect to each other e.g. widgets to the left,
buttons to the right instead of widgets on the top and buttons on
the bottom always.

=head1 AUTHOR

B<Rajappa Iyer> rsi@earthling.net

This code is distributed under the same terms as Perl.

=cut
