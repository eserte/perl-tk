# Copyright (c) 1995-1998 Nick Ing-Simmons. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
package Tk::Message;
use strict;

use vars qw($VERSION @ISA);
$VERSION = '3.005'; # $Id: //depot/Tk8/Tk/Message.pm#5$

require Tk::Widget;

@ISA = qw(Tk::Widget);

Construct Tk::Widget 'Message';

sub Tk_cmd { \&Tk::message }

1;
__END__

