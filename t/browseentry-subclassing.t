#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: browseentry-subclassing.t,v 1.4 2003/04/21 19:49:27 eserte Exp $
# Author: Slaven Rezic
#

use strict;

use Tk;
use Tk::BrowseEntry;

BEGIN {
    if (!eval q{
	use Test;
	use Tk::NumEntry;
	1;
    }) {
	print "1..0 # skip: no Test module\n";
	exit;
    }
}

BEGIN { plan tests => 2 }

if (!defined $ENV{BATCH}) { $ENV{BATCH} = 1 }

{
    package Tk::NumBrowseEntry;
    use base qw(Tk::BrowseEntry);
    use Tk::NumEntry;
    Construct Tk::Widget 'NumBrowseEntry';
    sub LabEntryWidget { "NumEntry" }
}

my $mw = my $top = tkinit;
my $ne = $mw->NumBrowseEntry(-minvalue => -10,
			     -maxvalue => +10,
			     -choices => [-6,-3,0,3,6],
			    )->pack;
ok($ne->isa('Tk::NumBrowseEntry'));

{
    package Tk::MyLabEntry;
    use base qw(Tk::Frame);
    Construct Tk::Widget 'MyLabEntry';

    sub Populate {
	my($cw, $args) = @_;
	$cw->SUPER::Populate($args);
	my $e = $cw->Component(Entry => 'entry');
	$e->pack('-expand' => 1, '-fill' => 'both');
	$cw->ConfigSpecs(DEFAULT => [$e]);
	$cw->Delegates(DEFAULT => $e);
	$cw->AddScrollbars($e) if (exists $args->{-scrollbars});
	$cw->ConfigSpecs(-background => ['SELF', 'DESCENDANTS'],
			 DEFAULT => [$e],);
    }
}

{
    package Tk::MyLabEntryBrowseEntry;
    use base qw(Tk::BrowseEntry);
    Construct Tk::Widget 'MyLabEntryBrowseEntry';
    sub LabEntryWidget { "MyLabEntry" }
}

$mw->optionAdd("*MyLabEntryBrowseEntry*Entry.background", "red");
my $le = $mw->MyLabEntryBrowseEntry(-label => "My LabEntry:")->pack;
ok($le->isa('Tk::MyLabEntryBrowseEntry'));

$top->Button(-text => "Ok",
	     -command => sub {
		$top->destroy;
	    })->pack;
$top->after(60*1000, sub { $top->destroy });

if (!$ENV{BATCH}) {
    MainLoop;
}

__END__
