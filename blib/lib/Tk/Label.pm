# Copyright (c) 1995-1997 Nick Ing-Simmons. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package Tk::Label; 
require Tk;


use vars qw($VERSION);
$VERSION = '2.006'; # $Id: //depot/Tk/Tk/Label.pm#6$

@ISA = qw(Tk::Widget);

Construct Tk::Widget 'Label';

sub Tk_cmd { \&Tk::label }

1;



