package Tk::Xlib;
require DynaLoader;
require Tk;
use Exporter;


use vars qw($VERSION);
$VERSION = '3.003'; # $Id: //depot/Tk8/Xlib/Xlib.pm#3$

@ISA = qw(DynaLoader Exporter);
@EXPORT_OK = qw(XDrawString XLoadFont XDrawRectangle);

bootstrap Tk::Xlib $Tk::VERSION;

1;
