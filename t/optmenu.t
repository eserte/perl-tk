# -*- perl -*-
BEGIN { $|=1; $^W=1; }
use strict;
use Test;

BEGIN 
  {
   plan test => 10;
  };

eval { require Tk };
ok($@, "", "loading Tk module");

eval { require Tk::Optionmenu };
ok($@, "", "loading Tk::Optionmenu module");

my $mw;
eval {$mw = Tk::MainWindow->new();};
ok($@, "", "can't create MainWindow");
ok(Tk::Exists($mw), 1, "MainWindow creation failed");

my $foo = 12;
my @opt = (0..20);

my $opt = $mw->Optionmenu(-variable => \$foo,
	                  -options => \@opt)->pack;
ok($@, "", "can't create Optionmenu");
ok(Tk::Exists($opt), 1, "Optionmenu creation failed");

ok($ {$opt->cget(-textvariable)}, $foo, "setting of -variable failed");

my $optmenu = $opt->cget(-menu);
ok($optmenu ne "", 1, "can't get menu from Optionmenu");
ok(ref $optmenu, 'Tk::Menu', "reference returned is not a Tk::Menu");
ok($optmenu->index("last"), 20, "wrong number of elements in menu");

1;
__END__
