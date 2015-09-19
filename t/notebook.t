#!/usr/bin/perl -w
# -*- cperl -*-

#
# Author: Slaven Rezic
#

use strict;
use Test::More;

use Tk;
use Tk::NoteBook;

my $mw = eval { tkinit };
plan skip_all => "Cannot create MainWindow: $@" if !$mw;

plan 'no_plan';
my $nb = $mw->NoteBook->pack(-fill => 'both', -expand => 1);
isa_ok $nb, 'Tk::NoteBook';

{
    my $page = $nb->add('page1', -label => 'page(1)');
    isa_ok $page, 'Tk::Frame';
    
    my @pages = $nb->pages;
    is_deeply \@pages, ['page1'];

    my $page_widget = $nb->page_widget('page1');
    is $page_widget, $page;

    is $nb->FindMenu('x'), undef;
}

{
    my $page = $nb->add('page2', -label => 'page(2)', -underline => 4);
    is $nb->FindMenu('x'), undef;
}

{
    my $page = $nb->add('page3', -label => 'page(3)', -underline => 0);
    is $nb->FindMenu('p'), $nb;
}

# MainLoop;

__END__
