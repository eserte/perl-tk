# Copyright (c) 1995-1998 Nick Ing-Simmons. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
package Tk::Message;
use AutoLoader;


use vars qw($VERSION);
$VERSION = '3.004'; # $Id: //depot/Tk8/Tk/Message.pm#4$

@ISA = qw(Tk::Widget);

Construct Tk::Widget 'Message';

sub Tk_cmd { \&Tk::message }

1;
__END__


