package Tk::NBFrame;
require Tk;

use vars qw($VERSION);
$VERSION = '3.009'; # $Id: //depot/Tk8/NBFrame/NBFrame.pm#9$

use base  qw(Tk::Widget);

Construct Tk::Widget 'NBFrame';

bootstrap Tk::NBFrame $Tk::VERSION;

sub Tk_cmd { \&Tk::nbframe }

Tk::Methods qw(activate add delete focus info geometryinfo identify
               move pagecget pageconfigure);

1;

