BEGIN { $|=1; $^W=1; }
use strict;
use Test;
use Tk;
plan test => 5;
my $var = 'One';
my $mw = MainWindow->new;
my $e  = $mw->Entry(-textvariable => \$var)->pack;
ok($e->get,$var,"Entry not initialized from variable");
$e->delete(0,'end');
ok($var,'',"Delete does not change variable");
$e->insert(0,'Two');
ok($var,'Two',"Insert does not change variable");
$var = 'Three';
ok($e->get,$var,"Entry does not track variable assignment");
chop($var);
ok($e->get,'Thre',"Entry does not track chop-ing variable");

