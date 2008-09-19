#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: $
# Author: Slaven Rezic
#

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

plan tests => 3;

use_ok 'Tk::ErrorDialog';

my $mw = tkinit;
$mw->geometry("+10+10");

my $errmsg = "Intentional error.";
$mw->after(100, sub { die "$errmsg\n" });

my $found_error_msg;
$mw->after(200, sub {
	       my $dialog;
	       $mw->Walk(sub {
			     return if $found_error_msg;
			     for my $opt (qw(text message)) {
				 my $val = eval { $_[0]->cget("-$opt") };
				 if (defined $val && $val =~ m{\Q$errmsg}) {
				     $found_error_msg = 1;
				     $dialog = $_[0]->toplevel;
				 }
			     }
			 });
	       isa_ok($dialog, "Tk::Dialog", "dialog");
	       $dialog->Exit;
	       $mw->after(100, sub { $mw->destroy });
	   });

MainLoop;
is($found_error_msg, 1, "Found error message in some dialog");

__END__
