# button.pl

use vars qw/$TOP/;

sub button {

    # Create a top-level window that displays a bunch of buttons.

    my($demo) = @ARG;
    my $demo_widget = $MW->WidgetDemo(
        -name     => $demo,
	-text     => 'If you click on any of the four buttons below, the background of the button area will change to the color indicated in the button.   You can press Tab to move among the buttons, then press Space to invoke the current button.',
        -title    => 'Button Demonstration',
        -iconname => 'button',
    );
    $TOP = $demo_widget->Top;	# get geometry master

    foreach my $color (qw/PeachPuff1 LightBlue1 SeaGreen2 Yellow1/) {  
	my $b = $TOP->Button(
            -text    => $color,
            -width   => 10,
            -command => sub {$TOP->configure(-background => lc($color))},
        );
	$b->pack(qw/-side top -expand yes -pady 2/);
    }

} # end button

1;
