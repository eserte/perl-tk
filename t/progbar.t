BEGIN { $^W = 1; $| = 1;}
use strict;
use Test;
use Tk;        
use Tk::widgets qw(ProgressBar);
                      
plan tests => 15;

my $mw  = MainWindow->new();
$mw->geometry('+100+100');

my $var = 0;

my $pb  = $mw->ProgressBar(-bd => 3, -relief => 'raised', -fg => 'blue', -variable => \$var)->pack;
ok(defined($pb),1,"Cannot create");

ok(defined(tied($var)),1,"Variable not tied");
ok($pb->cget('-from'),0,"Bad from");
ok($pb->cget('-to'),100,"Bad to");

for my $v (map(10*$_+3,1..10))
 {
  $var = $v;
  ok($pb->cget('-value'),$v,"Value not $v");
  $mw->update;
 }

$mw->destroy;
ok(defined(tied($var)),'',"Variable still tied");

