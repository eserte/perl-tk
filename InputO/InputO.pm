package Tk::InputO;
require Tk;

use vars qw($VERSION);
$VERSION = '3.009'; # $Id: //depot/Tk8/InputO/InputO.pm#9$

use base  qw(Tk::Widget);

Construct Tk::Widget 'InputO';

bootstrap Tk::InputO $Tk::VERSION;

sub Tk_cmd { \&Tk::inputo }

#Tk::Methods qw(add ...);

1;

