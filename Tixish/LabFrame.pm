#
# Labeled frame. Derives from Tk::Frame, but intercepts the labeling
# part.

package Tk::LabFrame;

use vars qw($VERSION);
$VERSION = '3.021'; # $Id: //depot/Tk8/Tixish/LabFrame.pm#21 $

use Tk;
require Tk::Frame;

use strict;
use base qw(Tk::Frame);
Construct Tk::Widget 'LabFrame';


sub Populate {
    my ($cw, $args) = @_;
    my $f;
    my $label;
    my $lside = exists $args->{-labelside} ?
	delete $args->{-labelside} : 'top';
    my $ltext = delete $args->{-label};
    $cw->SUPER::Populate($args);

    if ($lside =~ /acrosstop/) {
	my $border = $cw->Frame(-relief => 'groove', -bd => 2);
        $cw->Advertise('border' => $border);
	my $pad = $border->Frame;
	$f = $border->Frame;
	$label = $cw->Label(-text => $ltext);
	my $y = int($label->winfo('reqheight')) / 2;
	my $ph = $y - int($border->cget(-bd));
	if ($ph < 0) {
	    $ph = 0;
	}
	$label->form(-top => 0, -left => 4, -padx => 6, -pady => 2);
        # $label->place('-y' => 2, '-x' => 10);
	$border->form(-top => $y, -bottom => -1, -left => 0, -right => -1, -padx => 2, -pady => 2);
	$pad->form(-left => 0, -right => -1, -top => 0, -bottom => $ph);
	$f->form(-top => $pad, -bottom => -1, -left => 0, -right => -1);
	# $cw->Delegates('pack' => $cw);
    } else {
	$f = $cw->Frame(-relief => 'groove', -bd => 2, %{$args});
	$label = $cw->Label(-text => $ltext);
	$label->pack(-side => $lside);
	$f->pack(-side => $lside, -fill => 'both', -expand => 1);
    }
    $cw->Advertise('frame' => $f);
    $cw->Advertise('label' => $label);
    $cw->Delegates(DEFAULT => $f);
    $cw->ConfigSpecs(-labelside => ['PASSIVE', 'labelSide', 'LabelSide', 'acrosstop'],
		     'DEFAULT' => [$f]);
}

1;

__END__
