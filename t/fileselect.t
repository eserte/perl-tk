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
$f->directory;
ok($f->{Configure}{-filter}, "*", "filter not equal *");

$f = $top->FileSelect(-defaultextension => 'c');
$f->directory;
ok($f->{Configure}{-filter}, "*.c", "filter/defaultextension mismatch");

$f = $top->FileSelect(-filter => '*.c');
$f->directory;
ok($f->{Configure}{-filter}, "*.c", "filter not equal *.c");

1;
__END__
