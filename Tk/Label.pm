# Copyright (c) 1995-1999 Nick Ing-Simmons. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.

package Tk::Label;
require Tk;


use vars qw($VERSION);
$VERSION = '3.011'; # $Id: //depot/Tk8/Tk/Label.pm#11 $

use base  qw(Tk::Widget);

Construct Tk::Widget 'Label';

sub Tk_cmd { \&Tk::label }

1;



