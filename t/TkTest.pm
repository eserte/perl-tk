# Copyright (C) 2003 Slaven Rezic. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package TkTest;

use strict;
use vars qw(@EXPORT $eps $VERSION);
$VERSION = sprintf '4.%03d', q$Revision: #2 $ =~ /\D(\d+)\s*$/;

use base qw(Exporter);
@EXPORT = qw(ok_float);

use POSIX qw(DBL_EPSILON LDBL_EPSILON);
use Config;
use Test qw(ok);

if ($Config{uselongdouble}) {
    $eps = LDBL_EPSILON;
} else {
    $eps = DBL_EPSILON;
}


sub ok_float ($$;$) {
    my($value, $expected, $diag) = @_;
    my @value    = split /[\s,]+/, $value;
    my @expected = split /[\s,]+/, $expected;
    my $ok = 1;
    for my $i (0 .. $#value) {
	if ($expected[$i] =~ /^[\d+-]/) {
	    if (abs($value[$i]-$expected[$i]) > $eps) {
		$ok = 0;
		last;
	    }
	} else {
	    if ($value[$i] ne $expected[$i]) {
		$ok = 0;
		last;
	    }
	}
    }
    if ($ok) {
	@_ = (1, 1, $diag);
	goto &ok;
    } else {
	@_ = ($value, $expected, $diag);
	goto &ok;
    }
}

1;

__END__
