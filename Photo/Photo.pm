package Tk::Photo;
require DynaLoader;
require AutoLoader;
@ISA = qw(DynaLoader Tk::Image);

Tk::Image->Construct('Photo');

bootstrap Tk::Photo;

sub Tk_image { 'photo' }

1;
__END__
