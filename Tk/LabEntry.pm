# Copyright (c) 1995-1998 Nick Ing-Simmons. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
# Class LabeledEntry

package Tk::LabEntry;
require Tk::Frame;

use vars qw($VERSION);
$VERSION = '3.004'; # $Id: //depot/Tk8/Tk/LabEntry.pm#4$

@ISA = qw(Tk::Frame);

Construct Tk::Widget 'LabEntry';

sub Populate 
{
 require Tk::Entry;
 # LabeledEntry constructor.
 #
 my($cw, $args) = @_;
 $cw->SUPER::Populate($args);
 # Advertised subwidgets:  entry.
 my $e = $cw->Entry();
 $e->pack('-expand' => 1, '-fill' => 'both');
 $cw->Advertise('entry' => $e );
 $cw->ConfigSpecs(DEFAULT => [$e]);
 $cw->Delegates(DEFAULT => $e);
 $cw->AddScrollbars($e) if (exists $args->{-scrollbars});
} 

1;
