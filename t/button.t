#!/usr/bin/perl -w
# -*- perl -*-

use strict;

use Tk;

BEGIN {
    if (!eval q{
	use Test::More;
	1;
    }) {
	print "1..0 # skip: no Test::More module\n";
	exit;
    }
}

BEGIN { plan tests => 3 }

my $mw = MainWindow->new;
$mw->geometry("+10+10");

{
    my $cb = $mw->Checkbutton->pack;
    is(ref $cb, "Tk::Checkbutton");
    is($cb->{Value}, undef);
    $cb->select;
    is($cb->{Value}, 1);
}

__END__
