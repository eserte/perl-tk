#!/usr/bin/perl -w

use strict;
use Test;
use Tk;

plan tests => 1;

my $mw = tkinit;

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
