use Test::More (tests => 6);
use Tk;
my $mw = MainWindow->new;
$mw->withdraw;
my $start = time;
$mw->after(1000,sub { my $t = time;
                      isnt($t,$start);
                      ok( $t >= $start+1,"$t >= $start");
                      ok( $t <= $start+2 ) });
$mw->after(2000,sub { my $t = time;
                      ok( $t >= $start+2 );
                      ok( $t <= $start+3 ) });
$mw->after(3000,[destroy => $mw ]);
MainLoop;
ok(time >= $start+3);

