# Copyright (c) 1995-1996 Nick Ing-Simmons. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package Tk::Label; 
require Tk;

@ISA = qw(Tk::Widget); 

Tk::Widget->Construct('Label');

sub Tk_cmd { \&Tk::label }

1;



