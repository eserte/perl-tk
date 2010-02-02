#!/usr/bin/perl -w
# -*- perl -*-

#
# Author: Slaven Rezic
#

# Here goes tests for non-core Tk methods

use strict;
use Tk;

BEGIN {
    if (!eval q{
	use Test::More;
	1;
    }) {
	print "1..0 # skip no Test::More module\n";
	exit;
    }
}

plan tests => 6;

my $mw = MainWindow->new;
$mw->geometry("+10+10");

{
    my $t = $mw->Text(qw(-width 20 -height 10))->pack;
    $t->insert("end", "hello\nworld\nfoo\nbar\nworld\n");

    ok(!$t->FindNext('-f', '-e', '-c', 'doesnotexist'), 'Pattern does not exist');

    ok($t->FindNext('-f', '-e', '-c', 'world'), 'First search');
    my @first_index = split /\./, $t->index('insert');

    ok($t->FindNext('-forwards', '-e', '-c', 'world'), 'Second search');
    my @second_index = split /\./, $t->index('insert');
    cmp_ok($second_index[0], ">", $first_index[0], 'Really a forwards search');

    ok($t->FindNext('-b', '-e', '-c', 'world'), 'Backwards search');
    my @third_index = split /\./, $t->index('insert');
    cmp_ok($third_index[0], "<", $second_index[0], 'Really a backwards search');
}

__END__
