package Tk::InputO; 
require Tk;


use vars qw($VERSION);
$VERSION = '3.003'; # $Id: //depot/Tk8/InputO/InputO.pm#3$

@ISA = qw(Tk::Widget);

Construct Tk::Widget 'InputO';

bootstrap Tk::InputO $Tk::VERSION; 

sub Tk_cmd { \&Tk::inputo }

#EnterMethods Tk::InputO __FILE__,qw(add addchild anchor column
#                                   delete dragsite dropsite entrycget
#                                   entryconfigure geometryinfo hide item info
#                                   nearest see selection show xview yview);

1;

