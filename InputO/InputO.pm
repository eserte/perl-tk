package Tk::InputO; 
require Tk;
require DynaLoader;

@ISA = qw(DynaLoader Tk::Widget);

Tk::Widget->Construct('InputO');

bootstrap Tk::InputO $Tk::VERSION; 

sub Tk_cmd { \&Tk::inputo }

#EnterMethods Tk::InputO __FILE__,qw(add addchild anchor column
#                                   delete dragsite dropsite entrycget
#                                   entryconfigure geometryinfo hide item info
#                                   nearest see selection show xview yview);

1;

