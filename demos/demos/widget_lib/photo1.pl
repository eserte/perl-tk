# Transparent Photo pixels

use vars qw/$TOP/;

use Tk::PNG;

sub photo1 {

    my($demo) = @_;

    $TOP = $MW->WidgetDemo(
        -name             => $demo,
        -text             => 'This demonstration displays a picture of a flower on a green background for two seconds, the proceeeds to make a 50 x 50 pixel rectangular area transparent so that the green background shows through.',
        -title            => 'Photo Transparency',
        -iconname         => 'photo1',
    );

    my $l = $TOP->Label( qw/ -background green -width 500 -height 350 / )->pack;

    my $f1 = $TOP->Photo( -file => Tk->findINC('demos/images') . '/flower2.png' );
    $l->configure( -image => $f1 );
    $TOP->idletasks;
    $TOP->after(2000);

    foreach my $x ( 50 .. 100 ) {
	foreach my $y ( 50 .. 100 ) {
	    $f1->transparencySet( $x, $y, 1 );
	    $f1->update;
	}
    }

} # end photo1
