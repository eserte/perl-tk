BEGIN { $^W = 1; $| = 1;}
use strict;
use Test;
use Tk;        
use Tk::Photo;


my $mw  = MainWindow->new();
$mw->geometry('+100+100');

plan tests => (2*(5 * 5) + 2);

my @files = ();

my $row = 0;
foreach my $leaf('Tk.xbm','Xcamel.gif')
 {
  my $file = Tk->findINC($leaf);
  my $src = $mw->Photo(-file => $file);
  ok(defined($src),1," Cannot load $file");
  my $kind = 'Initial';
  my $col = 0;
  $mw->Label(-text  => 'Initial')->grid(-row => $row, -column => $col);
  $mw->Label(-background => 'white',-image => $src)->grid(-row => $row+1, -column => $col++);
  $mw->update;
    
  foreach $kind ($src->formats)
   {
    my $f = lc("t/test.$kind");
    my $p = $f;
    push(@files,$f);
    print "$kind - $f\n";
    eval { $src->write($f, -format => "$kind") };
    ok($@,''," write $@");
    ok($p,$f,"File name corrupted");
    ok(-f $f,1,"No $f created");
    my $new;
    eval { $new = $mw->Photo(-file => $f, -format => "$kind") };
    ok($@,''," load $@");
    ok(defined($new),1,"Could not load $f");
    $mw->Label(-text  => $kind)->grid(-row => $row, -column => $col);
    $mw->Label(-background => 'white', -image => $new)->grid(-row => $row+1, -column => $col++);
    $mw->update;
   }
 $row += 2; 
}

$mw->after(1000,[destroy => $mw]);
MainLoop;

foreach (@files)
 {               
  unlink($_) if -f $_;
 }               

