package Tk::Xlib;
require DynaLoader;
require Tk;
use Exporter;

@ISA = qw(DynaLoader Exporter);
@EXPORT_OK = qw(XDrawString XLoadFont XDrawRectangle);

bootstrap Tk::Xlib $Tk::VERSION;

1;
