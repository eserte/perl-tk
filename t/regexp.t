# -*- coding:utf-8; -*-
use strict;
use warnings;
use Test::More tests => 29;
use Tk;
use Tk::widgets qw(Text);
use utf8;

my $mw = MainWindow->new;
my $tw = $mw->Text;
my $all = <<'TEXT';

This is the text we are matching.
     $42
     £42
     €42
     İstanbul
     İİİİİİİİİİİİİİİİ
TEXT

$tw->insert(end => $all);
is($tw->get('1.0','end -1 char'),$all,"Contents as expected");

my $eposn;
my $ecoun;
my $ecount;

$eposn = $tw->search(-count => \$ecount, -exact => 'matching','1.0');
is($eposn,'2.24',"Correct -exact postion");
is($ecount,8,"Correct -exact length");

my $rposn;
my $rcount;

$rposn = $tw->search(-count => \$rcount, -regexp => 'matching','1.0');
is($rposn,'2.24',"Correct -regexp postion");
is($rcount,8,"Correct -regexp length");

$rposn = $tw->search(-count => \$rcount, -regexp => 'tHiS','1.0');
is($rposn,undef,"Correct non-match");

$eposn = $tw->search(-count => \$rcount, -nocase => -exact => 'tHiS','1.0');
is($eposn,'2.0',"Correct -exact -nocase");

$rposn = $tw->search(-count => \$rcount, -nocase => -regexp => 'tHiS','1.0');
is($rposn,'2.0',"Correct -regexp -nocase");

$eposn = $tw->search(-count => \$ecount, -nocase => -exact => '£42','1.0');
is($eposn,'4.5',"Correct -exact high-bit posn");
is($ecount,3,"Correct -exact high-bit len");

SKIP: {
  skip "perl regexp bug pre perl5.8.1", 2 if $] < 5.008001;
$rcount = 0;
$rposn = $tw->search(-count => \$rcount, -nocase => -regexp => '£42','1.0');
is($rposn,'4.5',"Correct -regexp high-bit posn");
is($rcount,3,"Correct -regexp high-bit len");
}

$eposn = $tw->search(-count => \$rcount, -nocase => -exact => '€42','1.0');
is($eposn,'5.5',"Correct -exact -nocase (unicode > U+0100)");

SKIP: {
  skip "perl regexp bug pre perl5.8.1", 2 if $] < 5.008001; # probably, not checked
$rcount = 0;
$rposn = $tw->search(-count => \$rcount, -nocase => -regexp => '€42','1.0');
is($rposn,'5.5',"Correct -regexp -nocase (unicode > U+0100)");
is($rcount,3,"Correct -regexp len (unicode > U+0100)");
}

$eposn = $tw->search(-count => \$rcount, -nocase => -exact => 'İstanbul','1.0');
is($eposn,'6.5',"Correct -exact -nocase (with unicode expanding)");

TODO: {
  local $TODO = "fails to find anything, or returns the wrong position (off because the lowercase variant has an additional combining character)";
$eposn = $tw->search(-count => \$rcount, -nocase => -exact => 'stanbul','1.0');
is($eposn,'6.6',"Correct -exact -nocase (with unicode expanding)");
}

$eposn = $tw->search(-count => \$rcount, -nocase => -exact => 'İİİİİİİİİİİİİİİİ','1.0');
is($eposn,'7.5',"Correct -exact -nocase (with unicode expanding)");

my $qposn;
my $qcount;

$qposn = $tw->search(-count => \$qcount, -regexp => qr/matching/,'1.0');
is($qposn,'2.24',"Correct -regexp qr// postion");
is($qcount,8,"Correct -regexp qr// length");

SKIP:  {
  skip "Perl too old", 8 unless $] >= 5.008001;
my $tword = qr/\bt\w+|\D\d+/i;
my $start = '1.0';
my $i = 0;
my @word = $all =~ /$tword/g;
while ($qposn = $tw->search(-count => \$qcount, -regexp => $tword,$start,'end'))
 {
  $start = $tw->index("$qposn +$qcount chars");
  my $s = $tw->get($qposn,$start);
  # print "# '$s'\n";
  is($s,$word[$i++],"Right word");
 }


$rposn = $tw->search(-count => \$rcount, -regexp => '£\d+','1.0');
$i     = $tw->get("$rposn+1 chars","$rposn + $rcount chars");
is($rposn,'4.5',"Correct -regexp postion");
is($rcount,3,"Correct -regexp length");
is($i,'42',"UTF-8 Skip correct");

}

