# hello.pl

use Config;
use File::Basename;
use Tk::widgets qw/ ROText /;
use vars qw/ $TOP /;
use strict;

sub hello {

    my( $demo ) = @_;

    $TOP = $MW->WidgetDemo(
        -name             => $demo,
        -text             => "This demonstration describes the basics of Perl/Tk programming.  MORE HERE, PLEASE.",
        -title            => 'Perl/Tk User Guide',
        -iconname         => 'hello',
    );

    # Pipe perldoc help output via fileevent() into a Scrolled ROText widget.

    my $t = $TOP->Scrolled(
        qw/ ROText -width 80 -height 25 -wrap none -scrollbars osow/,
    );
    my $cmd = dirname( $Config{perlpath} ) . '/perldoc -t Tk::UserGuide';
    $t->pack( qw/ -expand 1 -fill both / );

    open( H, "$cmd|" ) or die "Cannot get pTk user guide: $!";
    $TOP->fileevent( \*H, 'readable' => [ \&hello_fill, $t ] );

} # end hello

sub hello_fill {

    my( $t ) = @_;

    my $stat = sysread H, my $data, 4096;
    die "sysread error:  $!" unless defined $stat;
    if( $stat == 0 ) {		# EOF
	$TOP->fileevent( \*H, 'readable' => '' );
	return;
    }
    $t->insert( 'end', $data );

} # end hello_fill
