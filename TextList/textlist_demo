#!/usr/local/bin/perl -w

require 5;
use strict;  
#use lib qw(/home1/gbartels/textlist);

use Tk;
use Tk::TextList;

my $mw = MainWindow->new;


#my $obj = 'Listbox';
my $obj = 'TextList';

$mw->title($obj);

my @choices = qw 
/
alpha bravo charlie delta echo foxtrot golf hotel india juliet kilo
lima mike november oscar papa quebec romea sierra tango uniform victor
wiskey xray yankee zulu
/;


my $lb = $mw->Scrolled($obj)->pack;
$lb->insert('end', @choices);
$lb->configure(-selectmode=>'extended');

 $mw->bind('<F1>',
sub
{
	print "current selections are: \n";
	my @list = $lb->curselection;
	print join(' ',@list);
	print "\n\n\n";
});

 $mw->bind('<F2>',
sub
{
	print "current tags are: \n";
	my @list = $lb->tagNames;
	print join(' ',@list);
	print "\n\n\n";
	print "locations are :\n";
	foreach my $tag (@list)
		{
		my @indexes = $lb->tagRanges($tag);
		my $string = join (' ',@indexes);
		print "tag: $tag    locations = $string \n";
		}

});

$lb->tagConfigure('TEST_TAG', foreground=>'red');
$lb->tagAdd('TEST_TAG', 10,13);
$lb->tagAdd('TEST_TAG', 4);
$lb->tagAddChar('TEST_TAG', 1.4, 1.5);

$lb->configure(-width=>20);

MainLoop;
