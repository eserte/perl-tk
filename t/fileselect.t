# -*- perl -*-
BEGIN
  {
    $^W = 1;
    $| = 1;

    eval { require Test; };
    if ($@)
      {
        print "1..0\n";
        print STDERR "Test.pm module not installed. Grab it from CPAN. ";
        exit;
      }
    Test->import;
  }
use strict;

BEGIN { plan test => 5 };

eval { require Tk };
ok($@, "", "loading Tk module");

eval { require Tk::FileSelect };
ok($@, "", "loading Tk::FileSelect module");

my $top = new MainWindow;
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
