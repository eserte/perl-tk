package Tk::Bitmap;
require Tk;
require Tk::Image;
@ISA = qw(Tk::Image);

Construct Tk::Image 'Bitmap';

bootstrap Tk::Bitmap $Tk::VERSION;

sub Tk_image { 'bitmap' }

1;
__END__
