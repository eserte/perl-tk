# form.pl

use vars qw/$TOP/;

sub form {

    # Create a top-level window that displays a bunch of entries with 
    # tabs set up to move between them.

    my($demo) = @_;
    my $demo_widget = $MW->WidgetDemo(
        -name     => $demo,
        -text     => 'This window contains a simple form where you can type in the various entries and use tabs to move circularly between the entries.',
        -title    => 'Form Demonstration',
        -iconname => 'form',
    );
    $TOP = $demo_widget->Top;	# get geometry master

    foreach ('Name:', 'Address:', '', '', 'Phone:') {
	my $f = $TOP->Frame(qw/-borderwidth 2/);
	my $e = $f->Entry(qw/-relief sunken -width 40/);
	my $l = $f->Label(-text => $_);
	$f->pack(qw/-side top -fill x/);
	$e->pack(qw/-side right/);
	$l->pack(qw/-side left/);
	$e->focus if $_ eq 'Name:';
    }
    $TOP->bind('<Return>' => [$TOP => 'destroy']);

} # end form

1;
