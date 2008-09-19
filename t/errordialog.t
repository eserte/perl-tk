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
$mw->afterIdle(sub { die "$errmsg\n" });

my $ed;
$mw->after(100, sub {
	       my $dialog = search_error_dialog($mw);
	       isa_ok($dialog, "Tk::Dialog", "dialog");
	       $ed = $dialog;
	       $dialog->SelectButton('Stack trace');
	       second_error();
	   });

MainLoop;

sub second_error {
    $mw->afterIdle(sub { die "$errmsg\n" });
    $mw->after(100, sub {
		   my $dialog = search_error_dialog($mw);
		   is($ed, $dialog, "ErrorDialog reused");
		   $dialog->Exit;
		   $mw->after(100, sub { $mw->destroy });
	       });
}

sub search_error_dialog {
    my $w = shift;
    my $dialog;
    my $found_error_dialog;
    $w->Walk(sub {
		 return if $found_error_dialog;
		 for my $opt (qw(text message)) {
		     my $val = eval { $_[0]->cget("-$opt") };
		     if (defined $val && $val =~ m{\Q$errmsg}) {
			 $found_error_dialog = 1;
			 $dialog = $_[0]->toplevel;
		     }
		 }
	     });
    $dialog;
}

__END__
