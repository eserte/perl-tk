package Tk::Bitmap;
require DynaLoader;
require AutoLoader;
require Tk;
@ISA = qw(DynaLoader Tk::Image);

Tk::Image->Construct('Bitmap');

bootstrap Tk::Bitmap $Tk::VERSION;

sub Tk_image { 'bitmap' }

1;
__END__
