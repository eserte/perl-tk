package Tk::Photo;
require DynaLoader;
require AutoLoader;
require Tk;
@ISA = qw(DynaLoader Tk::Image);

Tk::Image->Construct('Photo');

bootstrap Tk::Photo $Tk::VERSION;

sub Tk_image { 'photo' }

1;
__END__
