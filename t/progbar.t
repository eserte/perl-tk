BEGIN { $^W = 1; $| = 1;}
use strict;
use Test::More;
use Tk;
use Tk::widgets qw(ProgressBar);

plan tests => 25;

my $mw  = MainWindow->new();
$mw->geometry('+100+100');

my $var = 0;

my $pb  = $mw->ProgressBar(-bd => 3, -relief => 'raised', -fg => 'blue', -variable => \$var)->pack;
ok defined($pb), "Create progress bar";

ok defined(tied($var)), "Variable tied";
is $pb->cget('-from'), 0, "from";
is $pb->cget('-to'), 100, "to";

for my $v (map(10*$_+3,1..10))
 {
  $var = $v;
  is $pb->cget('-value'), $v, "Value per cget is $v";
  is $pb->value, $v, "Value per method is $v";
  $mw->update;
 }

$mw->destroy;
ok !defined(tied($var)), "Variable is not tied anymore";

