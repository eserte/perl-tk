# Conversion from Tk4.0 button.tcl competed.
# Copyright (c) 1992-1994 The Regents of the University of California.
# Copyright (c) 1994 Sun Microsystems, Inc.
# Copyright (c) 1995-1997 Nick Ing-Simmons. All rights reserved.
# This program is free software; you can redistribute it and/or

# modify it under the same terms as Perl itself, subject 
# to additional disclaimer in license.terms due to partial
# derivation from Tk4.0 sources.

package Tk::Checkbutton;  
use AutoLoader;
require Tk::Button;

@ISA = qw(Tk::Button);

use vars qw($VERSION);
$VERSION = '2.007'; # $Id: //depot/Tk/Tk/Checkbutton.pm#7$



Construct Tk::Widget 'Checkbutton';

sub Tk_cmd { \&Tk::checkbutton }

1;
__END__

sub ClassInit
{
 my ($class,$mw) = @_;
 $mw->bind($class,"<Enter>", "Enter");
 $mw->bind($class,"<Leave>", "Leave");
 $mw->bind($class,"<1>", "Invoke");
 $mw->bind($class,"<space>", "Invoke");
 return $class;
}

sub Invoke
{
 my $w = shift;
 $w->invoke() unless($w->cget("-state") eq "disabled");
}

1;
