package Tk::Xlib;
require DynaLoader;
require Tk;
use Exporter;


use vars qw($VERSION);
$VERSION = '2.004'; # $Id: //depot/Tk/Xlib/Xlib.pm#4$

@ISA = qw(DynaLoader Exporter);
@EXPORT_OK = qw(XDrawString XLoadFont XDrawRectangle);

bootstrap Tk::Xlib $Tk::VERSION;

1;
