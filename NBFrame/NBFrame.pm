package Tk::NBFrame; 
require Tk;
require DynaLoader;

@ISA = qw(DynaLoader Tk::Widget);

Tk::Widget->Construct('NBFrame');

bootstrap Tk::NBFrame $Tk::VERSION; 

sub Tk_cmd { \&Tk::nbframe }

#EnterMethods Tk::NBFrame __FILE__,qw(add addchild anchor column
#                                   delete dragsite dropsite entrycget
#                                   entryconfigure geometryinfo hide item info
#                                   nearest see selection show xview yview);

1;

