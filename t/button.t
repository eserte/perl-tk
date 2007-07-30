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

BEGIN { plan tests => 4 }

my $mw = MainWindow->new;
$mw->geometry("+10+10");

{
    my $cb = $mw->Checkbutton->pack;
    is(ref $cb, "Tk::Checkbutton", "It's a checkbutton");
    is($cb->{Value}, undef, "No value at beginning");
    $cb->select;
    is($cb->{Value}, 1, "... but now");
}

{
    # new Button options
    my $f = $mw->Frame->pack(-fill => 'x');
    my $incr = 0;
    $f->Button(-text => "Repeat & ridge",
	       -overrelief => 'ridge',
	       -repeatdelay => 200,
	       -repeatinterval => 100,
	       -command => sub { $incr++ },
	      )->pack(-side => 'left');
    $f->Label(-text => "increments:")->pack(-side => 'left');
    $f->Label(-textvariable => \$incr)->pack(-side => 'left');
    pass("Button with new options");
}

if ($ENV{PERL_INTERACTIVE_TEST}) {
    MainLoop;
}

__END__
