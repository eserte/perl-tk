package Tk::Pixmap;
require DynaLoader;
require AutoLoader;
require Tk;
require Tk::Image;

@ISA = qw(DynaLoader Tk::Image);

Tk::Image->Construct('Pixmap');

bootstrap Tk::Pixmap;

sub Tk_image { 'pixmap' }


1;
__END__
