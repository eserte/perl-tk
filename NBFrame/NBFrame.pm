package Tk::NBFrame;

use vars qw($VERSION);
$VERSION = '3.013'; # $Id: //depot/Tk8/NBFrame/NBFrame.pm#13 $

use Tk qw($XS_VERSION);

use vars qw($VERSION);
$VERSION = '3.013'; # $Id: //depot/Tk8/NBFrame/NBFrame.pm#13 $

use base  qw(Tk::Widget);

Construct Tk::Widget 'NBFrame';

bootstrap Tk::NBFrame;

sub Tk_cmd { \&Tk::nbframe }

Tk::Methods qw(activate add delete focus info geometryinfo identify
               move pagecget pageconfigure);

1;

