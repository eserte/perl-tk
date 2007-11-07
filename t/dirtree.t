#!/usr/bin/perl -w
# -*- perl -*-

use strict;

use Tk;

BEGIN {
    if (!eval q{
	use Test::More;
	use File::Spec;
	1;
    }) {
	print "1..0 # skip: no Test::More and/or File::Spec modules\n";
	exit;
    }
}

plan tests => 5;

if (!defined $ENV{BATCH}) { $ENV{BATCH} = 1 }

use_ok('Tk::DirTree');

my $mw = new MainWindow;
$mw->geometry("+10+10");
$mw->Button(
            -text => 'exit',
            -command => sub { pass('use clicked exit'); $mw->destroy; },
           )->pack(qw( -side bottom -pady 6 ));
my $f = $mw->Scrolled('DirTree',
                      -width => 55,
                      -height => 33,
                      -directory => File::Spec->rootdir(),
                     )->pack(qw( -fill both -expand 1 ));
pass('after create, with -directory option');
my $tree = $f->Subwidget();
isa_ok($tree, 'Tk::DirTree');
$mw->update;
if ($ENV{BATCH}) {
    $mw->after(300, sub { $mw->destroy });
}
pass('before MainLoop');
MainLoop;
pass('after MainLoop');

__END__
