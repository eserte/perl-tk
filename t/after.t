my $divisor;
use Test::More (tests => 6);
use Tk;
use strict;
BEGIN {
    eval 'use Time::HiRes qw(time)';
    $divisor = $@ ? 1 : 10;
}
my $mw = MainWindow->new;
$mw->withdraw;
my $start = time;
$mw->after(1000/$divisor,sub { my $t = time;
			       isnt($t,$start);
			       cmp_ok($t, ">=", $start+1/$divisor,"$t >= $start");
			       cmp_ok($t, "<=", $start+3/$divisor) });
$mw->after(2000/$divisor,sub { my $t = time;
			       cmp_ok($t, ">=", $start+2/$divisor);
			       cmp_ok($t, "<=", $start+4/$divisor) });
$mw->after(3000/$divisor,[destroy => $mw ]);
MainLoop;
cmp_ok(time, ">=", $start+3/$divisor);

