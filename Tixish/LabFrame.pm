#
# Labeled frame. Derives from Tk::Frame, but intercepts the labeling
# part.

package Tk::LabFrame;

use vars qw($VERSION);
$VERSION = '3.008'; # $Id: //depot/Tk8/Tixish/LabFrame.pm#8$

use Tk;
require Tk::Frame;

use strict;

Tk::Widget->Construct("LabFrame");

@Tk::LabFrame::ISA = qw(Tk::Frame);

sub Populate {
    my ($cw, $args) = @_;
    my $f;
    my $label;
    my $lside = exists $args->{-labelside} ?
	delete $args->{-labelside} : 'top';
    my $ltext = delete $args->{-label};
    $cw->SUPER::Populate($args);
    
    if ($lside =~ /acrosstop/) {
	my $border = $cw->Frame(-relief => "groove", -bd => 2);
	my $pad = $border->Frame;
	$f = $border->Frame;
	$label = $cw->Label(-text => $ltext);
	my $y = int($label->winfo('reqheight')) / 2;
	my $ph = $y - int($border->cget(-bd));
	if ($ph < 0) {
	    $ph = 0;
	}
	$label->form(-top => 0, -left => 4, -padx => 6, -pady => 2);
	$border->form(-top => $y, -bottom => -1, -left => 0, -right => -1, -padx => 2, -pady => 2);
	$pad->form(-left => 0, -right => -1, -top => 0, -bottom => $ph);
	$f->form(-top => $pad, -bottom => -1, -left => 0, -right => -1);
	$cw->Delegates('pack' => $cw);
    } else {
	$f = $cw->Frame(-relief => 'groove', -bd => 2, %{$args});
	$label = $cw->Label(-text => $ltext);
	$label->pack(-side => $lside);
	$f->pack(-side => $lside, -fill => 'both', -expand => 1);
    }
    $cw->Advertise('frame' => $f);
    $cw->Advertise('label' => $label);
    $cw->Delegates(DEFAULT => $f);
    $cw->ConfigSpecs(-labelside => ["PASSIVE", "labelSide", "LabelSide", "acrosstop"],
		     "DEFAULT" => [$f]);
}

=head1 NAME

Tk::LabFrame - labeled frame.

=for category Tix Extensions

=head1 SYNOPSIS

    use Tk::LabFrame;
    $f = $top->LabFrame(-label => "Something",
			-labelside => 'acrosstop');

=head1 DESCRIPTION

B<LabFrame> is exactly like B<Frame> except that it takes two
additional options:

=over 4

=item B<-label>
The text of the label to be placed with the Frame.

=item B<-labelside>
Can be one of B<left>, B<right>, B<top>, B<bottom> or B<acrosstop>.
The first four work as might be expected and place the label to the
left, right, above or below the frame respectively. The last one
creates a grooved frame around the central frame and puts the label
near the northwest corner such that it appears to "overwrite" the
groove. Run the following test program to see this in action:

    use Tk;
    require Tk::LabFrame;
    require Tk::LabEntry;

    my $test = 'Test this';
    $top = MainWindow->new;
    my $f = $top->LabFrame(-label => "This is a label",
			   -labelside => "acrosstop");
    $f->LabEntry(-label => "Testing", -textvariable => \$test)->pack;
    $f->pack;
    MainLoop;
    
=back
    
=head1 BUGS

Perhaps B<LabFrame> should be subsumed within the generic pTk
labeled widget mechanism.
    
=head1 AUTHOR

B<Rajappa Iyer> rsi@earthling.net

This code is derived from LabFrame.tcl and LabWidg.tcl in the Tix4.0
distribution by Ioi Lam. The code may be redistributed under the same
terms as Perl.
    
=cut
