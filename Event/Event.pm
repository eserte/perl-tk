package Tk::Event;
use vars qw($VERSION $XS_VERSION @EXPORT_OK);
END { CleanupGlue() }
$VERSION = '3.019'; # $Id: //depot/Tk8/Event/Event.pm#19 $
$XS_VERSION = '800.019';
require DynaLoader;
use base  qw(Exporter DynaLoader);
@EXPORT_OK = qw($XS_VERSION DONT_WAIT WINDOW_EVENTS  FILE_EVENTS
                TIMER_EVENTS IDLE_EVENTS ALL_EVENTS);
bootstrap Tk::Event;
require   Tk::Event::IO;
1;
__END__
