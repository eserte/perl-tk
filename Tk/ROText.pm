# Copyright (c) 1995-1999 Nick Ing-Simmons. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
require Tk;
package Tk::ROText;
require Tk::Text;

use vars qw($VERSION);
$VERSION = '3.021'; # $Id: //depot/Tk8/Tk/ROText.pm#21$

use base  qw(Tk::Text);
Construct Tk::Widget 'ROText';

sub clipEvents
{
 return qw[Copy];
}

sub ClassInit
{
 my ($class,$mw) = @_;
 my $val = $class->bindRdOnly($mw);
 my $cb  = $mw->bind($class,'<Next>');
 $mw->bind($class,'<space>',$cb) if (defined $cb);
 $cb  = $mw->bind($class,'<Prior>');
 $mw->bind($class,'<BackSpace>',$cb) if (defined $cb);
 $class->clipboardOperations($mw,'Copy');
 return $val;
}

sub Tk::Widget::ScrlROText { shift->Scrolled('ROText' => @_) }

1;

__END__

