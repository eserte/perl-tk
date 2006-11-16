#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: $
# Author: Slaven Rezic
#

use strict;

use File::Copy qw(cp);
use File::Spec::Functions qw(catfile);
use File::Temp qw(tempdir);

use Tk;
use Tk::FBox;

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

my $dir = tempdir(CLEANUP => 1);
die "Cannot create temporary directory" if !$dir;

my $mw = tkinit;
$mw->geometry("+10+10");

my $umlautdir = catfile $dir, "äöüß";
mkdir $umlautdir
    or die "Cannot create $umlautdir: $!";

my $umlautfile = catfile $umlautdir, "äöüß.gif";
cp(Tk->findINC("Xcamel.gif"), $umlautfile)
    or die "Can't copy Xcamel.gif to $umlautfile: $!";

{
    local $TODO = "Filenames with non-ascii chars are scrambled still";

    my $l = eval { $mw->Label(-image => $mw->Photo(-file => $umlautfile)) };
    is($@, "", "Create an image with non-ascii chars in filename");
    $l->destroy if Tk::Exists($l);
}

{
    my $fb = $mw->FBox;
    $fb->configure(-initialdir => $umlautdir);
    $fb->after(500, sub { $fb->destroy });
    $fb->Show;
    pass("Setting FBox -initialdir with non-ascii directory name");
}

{
    my $fb = $mw->FBox;
    $fb->configure(-initialfile => $umlautfile);
    $fb->after(500, sub { $fb->destroy });
    $fb->Show;
    pass("Setting FBox -initialfile with non-ascii file name");
}

__END__
