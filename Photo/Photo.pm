package Tk::Photo;
require Tk;
@ISA = qw(Tk::Image);

Construct Tk::Image 'Photo';

bootstrap Tk::Photo $Tk::VERSION;

sub Tk_image { 'photo' }

1;
__END__
