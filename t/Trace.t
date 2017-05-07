use strict;
use Test::More;
use Tk;
plan tests => 7;
my $var = 'One';
my $mw = MainWindow->new;
my $e  = $mw->Entry(-textvariable => \$var)->pack;
is($e->get,$var,"Entry initialized from variable");
$e->delete(0,'end');
is($var,'',"Delete changes variable");
$e->insert(0,'Two');
is($var,'Two',"Insert changes variable");
$var = 'Three';
is($e->get,$var,"Entry tracks variable assignment");
chop($var);
is($e->get,'Thre',"Entry tracks chop-ing variable");

my $nv;
$mw->Entry(-textvariable => \$nv);
$nv = 3/2;
is($nv, 3/2, "IV does not override NV");

my $pv_chop = 421;
chop($pv_chop);
$mw->Entry(-textvariable => \$pv_chop);
is($pv_chop, "42", "PV flag set");

__END__
