package Tk::MsgBox;

# msgBox - a translation of tk_messageBox() from Tcl/Tk to Perl/Tk.
#
# Just derive from Tk::Dialog so it does most of the work.
#
# Stephen.O.Lidie@Lehigh.EDU, Lehigh University Computing Center.  98/05/25

use strict;

use vars qw($VERSION);
$VERSION = '3.007'; # $Id: //depot/Tk8/Tk/MsgBox.pm#7$

use Tk::Dialog;
use base  'Tk::Dialog';
Construct Tk::Widget 'MsgBox';

sub Populate {

    my($cw, $args) = @_;

    # print "in MsgBox populate, args=@_!\n";
    $cw->SUPER::Populate($args);

    $args->{-bitmap} = delete $args->{-icon} if defined $args->{-icon};
    $args->{-text} = delete $args->{-message} if defined $args->{-message};
    $args->{-type} = 'OK' unless defined $args->{-type};

    my $type;
    if (defined($type = delete $args->{-type})) {
	delete $args->{-type};
	my @buttons;
	if ($type eq 'AbortRetryIgnore') {
	    @buttons = qw/Abort Retry Ignore/;
	} elsif ($type eq 'OK') {
	    @buttons = qw/OK/;
	} elsif ($type eq 'OKCancel') {
	    @buttons = qw/OK Cancel/;
	} elsif ($type eq 'RetryCancel') {
	    @buttons = qw/Retry Cancel/;
	} elsif ($type eq 'YesNo') {
	    @buttons = qw/Yes No/;
	} elsif ($type eq 'YesNoCancel') {
	    @buttons = qw/Yes No cancel/;
	}
	$args->{-buttons} = \@buttons;
	$cw->{-default_button_text} = delete $args->{-default} if defined $args->{-default};
	if (not defined $cw->{-default_button_text} and scalar(@buttons) == 1) {
	   $cw->{-default_button_text} = $buttons[0];
	}
    }

} # end Populate

1;
