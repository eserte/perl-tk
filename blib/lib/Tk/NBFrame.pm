package Tk::NBFrame; 
require Tk;


use vars qw($VERSION);
$VERSION = '2.005'; # $Id: //depot/Tk/NBFrame/NBFrame.pm#5$

@ISA = qw(Tk::Widget);

Construct Tk::Widget 'NBFrame';

bootstrap Tk::NBFrame $Tk::VERSION; 

sub Tk_cmd { \&Tk::nbframe }

EnterMethods Tk::NBFrame __FILE__,qw(activate add delete
				     focus info 
				     geometryinfo identify move pagecget
				     pageconfigure);
1;

