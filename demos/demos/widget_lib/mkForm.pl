

sub mkForm {

    # Create a top-level window that displays a bunch of entries with tabs set up to move between them.

    $mkForm->destroy if Exists($mkForm);
    $mkForm = $top->Toplevel();
    my $w = $mkForm;
    dpos $w;
    my(@pl) = (-side => 'top', -fill => 'x');      # packing list
    my(@ll) = ('Name:', 'Address:', '', '', 'Phone:'); # label list
    $w->title('Form Demonstration');
    $w->iconname('Form');
    my $w_msg = $w->Label(-font => '-Adobe-times-medium-r-normal--*-180-*-*-*-*-*-*', -wraplength => '4i',
			   -justify => 'left', -text => 'This window contains a simple form where you can type in the ' .
			   'various entries and use tabs to move circularly between the entries.  Click the "OK" button ' .
			   'or type return when you\'re done.');
    $w_msg->pack(@pl);
    my $i = 1;
    while ($i <= 5) {
	my $f = $w->Frame(-bd => '1m');
	my $e = $f->Entry(-relief => 'sunken', -width => '40');
	my $l = $f->Label(-text => $ll[$i-1]);
	$e->bind('<Return>', ['destroy', $w]);
	$f->pack(@pl);
	$e->pack(-side => 'right');
	$l->pack(-side => 'left');
	$i++;
    }
    my $w_ok = $w->Button(-text => 'OK', -width => 8, -command => ['destroy', $w]);
    $w_ok->pack(-side => 'top');

} # end mkForm


1;
