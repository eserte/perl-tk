package Tk::Xlib;
require DynaLoader;

use vars qw($VERSION);
$VERSION = '3.010'; # $Id: //depot/Tk8/Xlib/Xlib.pm#10 $

use Tk qw($XS_VERSION);
use Exporter;

use base  qw(DynaLoader Exporter);
@EXPORT_OK = qw(XDrawString XLoadFont XDrawRectangle);

bootstrap Tk::Xlib;

1;
