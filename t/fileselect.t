# -*- perl -*-
BEGIN { $|=1; $^W=1; }
use strict;
use Test;

BEGIN { plan test => 5 };

eval { require Tk };
ok($@, "", "loading Tk module");

eval { require Tk::FileSelect };
ok($@, "", "loading Tk::FileSelect module");

my $top = new MainWindow;
eval { $top->geometry('+10+10'); };  # This works for mwm and interactivePlacement
my $f = $top->FileSelect;
ok($f->cget('-filter'), "*", "filter not equal *");

$f = $top->FileSelect(-defaultextension => 'c');
ok($f->cget('-filter'), "*.c", "filter/defaultextension mismatch");

$f = $top->FileSelect(-filter => '*.h');
ok($f->cget('-filter'), "*.h", "filter not equal *.h");

1;
__END__
