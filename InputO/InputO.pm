package Tk::InputO;

use vars qw($VERSION);
$VERSION = '3.014'; # $Id: //depot/Tk8/InputO/InputO.pm#14 $

use Tk qw($XS_VERSION);
use base  qw(Tk::Widget);

Construct Tk::Widget 'InputO';

bootstrap Tk::InputO;

sub Tk_cmd { \&Tk::inputo }

#Tk::Methods qw(add ...);

1;

