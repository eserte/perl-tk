package Tk::Bitmap;
require DynaLoader;
require AutoLoader;
@ISA = qw(DynaLoader Tk::Image);

Tk::Image->Construct('Bitmap');

bootstrap Tk::Bitmap;

sub Tk_image { 'bitmap' }

1;
__END__
