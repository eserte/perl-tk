package Tk::Xlib;
require DynaLoader;
require Tk;
use Exporter;


use vars qw($VERSION @EXPORT_OK);
$VERSION = '3.006'; # $Id: //depot/Tk8/Xlib/Xlib.pm#6$

use base  qw(DynaLoader Exporter);
@EXPORT_OK = qw(XDrawString XLoadFont XDrawRectangle);

bootstrap Tk::Xlib $Tk::VERSION;

1;
