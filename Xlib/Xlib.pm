package Tk::Xlib;
require DynaLoader;
use Exporter;

@ISA = qw(DynaLoader Exporter);
@EXPORT_OK = qw(XDrawString XLoadFont XDrawRectangle);

bootstrap Tk::Xlib;

1;
