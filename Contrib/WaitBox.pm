##########################################
##########################################
##					##
##	WaitBox - a reusable Tk-widget	##
##		  Wait Dialog		##
##					##
##	Version 1.1			##
##					##
##	Brent B. Powers	(B2Pi)		##
##	Merrill Lynch			##
##	powers@swaps-comm.ml.com	##
##					##
##					##
##########################################
##########################################

###############################################################################
###############################################################################
## WaitBox
##    Object Oriented Wait Dialog for TkPerl
##    (Apologies to John Stoffel and Stephen O. Lidie)
##

## Changes:
## Ver 1.1 Changed show to Show, unshow to unShow, and general
##         cleanup for perl5.002 gamma

=head1 NAME

Tk::WaitBox - An Object Oriented Wait Dialog for Perl/Tk, of the Please Wait variety.

=head1 DESCRIPTION

A WaitBox consists of a number of subwidgets:

=over 4

=item

=head2 bitmap

A bitmap (configurable via the I<-bitmap> command, the default is an hourglass) on the left side of the WaitBox

=head2 label

A label (configurable via the I<-txt1> command), with text in the upper portion of the right hand frame

=head2 secondary label

Another label (configurable via the I<-txt2> command, the default is 'Please Wait'), with text in the lower portion of the right hand frame

=head2 userframe

A frame displayed, if required, between the label and the secondary label.  For details, see the example code and the Advertised Widget section

=head2 cancel button

If a cancelroutine (configured via the I<-cancelroutine> command) is defined, a frame will be packed below the labels and bitmap, with a single button.  The text of the button will be 'Cancel' (configurable via the I<-canceltext> command), and the button will call the supplied subroutine when pressed.

=back

=head1 SYNOPSIS

=over 4

=item Usage Description

=item

=head2 Basic Usage

To use, create your WaitDialog objects during initialization, or at least before a Show.  When you wish to display the WaitDialog object, invoke the 'Show' method on the WaitDialog object; when you wish to cease displaying the WaitDialog object, invoke the 'unShow' method on the object.

=head2 Configuration

Configuration may be done at creation or via the configure method.  

=head2 Example Code

=item

 #!/usr/local/bin/perl -w 

 use Tk;
 use Tk::WaitBox;
 use strict;

 my($root) = MainWindow->new;
 my($utxt) = "Initializing...";

 my($wd) = $root->WaitBox(
	-bitmap =>'questhead', # Default would be 'hourglass'
	-txt2 => 'tick-tick-tick', #default would be 'Please Wait'
	-title => 'Takes forever to get service around here',
	-cancelroutine => sub {
	    print "\nI'm canceling....\n";
	    $wd->unShow;
	    $utxt = undef;
	});
 $wd->configure(-txt1 => "Hurry up and Wait, my Drill Sergeant told me");
 $wd->configure(-foreground => 'blue',-background => 'white');

 ### Do something quite boring with the user frame
 my($u) = $wd->{SubWidget}(uframe);
 $u->pack(-expand => 1, -fill => 'both');
 $u->Label(-textvariable => \$utxt)->pack(-expand => 1, -fill => 'both');

 ## It would definitely be better to do this with a canvas... this is dumb
 my($base) = $u->Frame(-background =>'gray',
		       -relief => 'sunken',
		       -borderwidth => 2,
		       -height => 20)
	 ->pack(-side => 'left', -anchor => 'w',-expand => 1,
		-fill => 'both');
 my($bar) = $base->Frame(-borderwidth => 2,
			 -relief => 'raised', -height => 20,
			 -width => 0, -background => 'blue')
	 ->pack(-fill => 'y', -side => 'left');

 $wd->configure(-canceltext => 'Halt, Cease, Desist'); # default is 'Cancel'

 $wd->Show;

 for (1..15) {
     sleep(1);
     $bar->configure(-width => int($_/15*$base->Width));
     $utxt = 100*$_/15 . "% Complete";
     $root->update;
     last if !defined($utxt);
 }

 $wd->unShow;

=back


=head1 Advertised Subwidgets

=over 4

=item uframe

uframe is a frame created between the two messages.  It may be used for anything the user has in mind... including exciting cycle wasting displays of sand dropping through an hour glass, Zippy riding either a Gnu or a bronc, et cetera.

Assuming that the WaitBox is referenced by $w, the uframe may be addressed as $w->subwidget{'uframe'}.  Having gotten the address, you can do anything (I think) you would like with it

=back

=head1 Author

B<Brent B. Powers, Merrill Lynch (B2Pi)>
 powers@ml.com

This code may be distributed under the same conditions as perl itself.


=cut

###############################################################################
###############################################################################

package Tk::WaitBox;
use strict;
require Tk::Toplevel;

@Tk::WaitBox::ISA = qw (Tk::Toplevel);

Construct Tk::Widget 'WaitBox';

### A couple of convenience variables
my(@wd_fullpack) = (-expand => 1, -fill => 'both');
my(@wd_packtop) = (-side => 'top');
my(@wd_packleft) = (-side => 'left');


sub Populate {
    ### Wait box constructor.  Uses new inherited from base class
    my($cw, @args) = @_;

    $cw->SUPER::Populate(@args);

    ## Create the toplevel window
    $cw->withdraw;
    $cw->protocol('WM_DELETE_WINDOW' => sub {});
    $cw->transient($cw->toplevel);

    ### Set up the status
    $cw->{'Shown'} = 0;

    ### Set up the cancel button and text
    $cw->{'cancelroutine'} = undef if !defined($cw->{'cancelroutine'});
    $cw->{'canceltext'} = 'Cancel' if !defined($cw->{'canceltext'});

    ### OK, create the dialog
    ### Start with the upper frame (which contains two messages)
    ## And maybe more....
    my($wdtop) = $cw->Frame;
    $wdtop->pack(@wd_fullpack, @wd_packtop);

    my($fm) = $wdtop->Frame(-borderwidth => 2, -relief => 'raised');
    $fm->pack(@wd_packleft, -ipadx => 20, @wd_fullpack);

    my($bitmap) = $fm->Label(Name => 'bitmap');
    $bitmap->pack(@wd_packleft, -ipadx => 36, @wd_fullpack);

    ## Text Frame
    $fm = $wdtop->Frame(-borderwidth => 2, -relief => 'raised');
    $fm->pack(@wd_packleft, -ipadx => 20, @wd_fullpack);

    my($txt1) = $fm->Label(-wraplength => '3i', -justify => 'center',
			     -textvariable => \$cw->{Configure}{-txt1});
    $txt1->pack(@wd_packtop, -pady => 3, @wd_fullpack);

    ### Eventually, I want to create a user configurable frame
    ### in between the two frames
    my($uframe) = $fm->Frame;
    $uframe->pack(@wd_packtop);
    $cw->Advertise(uframe => $uframe);

    $cw->{Configure}{-txt2} = "Please Wait"
	    unless defined($cw->{Configure}{-txt2});

    my($txt2) = $fm->Label(-textvariable => \$cw->{Configure}{-txt2});
    $txt2->pack(@wd_packtop, @wd_fullpack, -pady => 9);

    ### We'll let the cancel frame and button wait until Show time

    ### Set up configuration
    $cw->ConfigSpecs(-bitmap	=> [$bitmap, undef, undef, 'hourglass'],
		     -foreground=> [[$txt1,$txt2], 'foreground','Foreground','black'],
		     -background=> ['DESCENDANTS', 'background', 'Background',undef],
		     -font	=> [$txt1,'font','Font','-Adobe-Helvetica-Bold-R-Normal--*-180-*'],
		     -canceltext=> ['PASSIVE', undef, undef, 'Cancel'],
		     -cancelroutine=> ['PASSIVE', undef, undef, undef],
		     -txt1	=> ['PASSIVE', undef, undef, undef],
		     -txt2	=> ['PASSIVE',undef,undef,undef],
		     -resizeable => ['PASSIVE',undef,undef,1]);
}

sub Show {
    ## Do last minute configuration and Show the dialog
    my($wd, @args) = @_;

    if ( defined($wd->{Configure}{-cancelroutine}) &&
	!defined($wd->{'CanFrame'})) {
	my($canFrame) = $wd->Frame (-background => $wd->cget('-background'));
	$wd->{'CanFrame'} = $canFrame;
	$canFrame->pack(-side => 'top', @wd_packtop, -fill => 'both');
	$canFrame->configure(-cursor => 'top_left_arrow');
	$canFrame->Button(-text => $wd->{Configure}{-canceltext},
			  -command => $wd->{Configure}{-cancelroutine})
		->pack(-padx => 5, -pady => 5,
		       -ipadx => 5, -ipady => 5);
    }

    ## Grab the input queue and focus
    $wd->parent->configure(-cursor => 'watch');
    $wd->configure(-cursor => 'watch');
    $wd->update;

    my($x) = int( ($wd->screenwidth
		 - $wd->reqwidth)/2
		 - $wd->vrootx);

    my($y) = int( ($wd->screenheight
		 - $wd->reqheight)/2
		 - $wd->vrooty);

    $wd->geometry("+$x+$y");

    $wd->{'Shown'} = 1;

    $wd->deiconify;
    $wd->tkwait('visibility', $wd);

    $wd->grab();
    $wd->focus();
    $wd->update;

    return $wd;

}

sub unShow {
    my($wd) = @_;

    return if !$wd->{'Shown'};
    $wd->{'CanFrame'}->destroy if (defined($wd->{'CanFrame'}));
    $wd->{'CanFrame'} = undef;
    $wd->parent->configure(-cursor => 'top_left_arrow');

    $wd->grab('release');
    $wd->withdraw;
    $wd->parent->update;
    $wd->{'Shown'} = 0;
}

1;

__END__
From  powers@swaps.ml.com  Fri Mar  1 07:19:41 1996 
Return-Path: <powers@swaps.ml.com> 
From: powers@swaps.ml.com (Brent B. Powers Swaps Programmer X2293)
Date: Fri, 1 Mar 1996 02:19:28 -0500 
Message-Id: <199603010719.CAA16433@swapsdvlp02.ny-swaps-develop.ml.com> 
To: nik@tiuk.ti.com 
Subject: WaitBox.pm 
P-From: "Brent B. Powers Swaps Programmer x2293" <powers@swaps.ml.com> 

Greetings.  Attached is a slightly updated version of WaitBox.pm to go
out (hopefully) with the next release of Tk.  It now works properly
under perl5.002gamma.  Could you please let me know that you did get
this... We're having some trouble with mail gateways.

Cheers.

Brent B. Powers             Merrill Lynch          powers@swaps.ml.com
