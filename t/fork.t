#!/usr/bin/perl -w

use strict;
use Test;
use Tk;

if ($^O eq 'MSWin32' || $^O eq 'cygwin') {
    print "1..0 # skip: No fork on Windows-like systems\n";
    exit;
}

plan tests => 1;

my $mw = tkinit;
$mw->geometry("+10+10");

if ($^O ne 'MSWin32' && fork == 0) {
    print "# Child $$\n";
    CORE::exit();
}
else {
  print "# Parent $$\n";
}
# Pause to allow child to exit
select undef, undef, undef, 0.5;
$mw->update;
ok(1);

__END__
