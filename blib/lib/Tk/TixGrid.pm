package Tk::TixGrid; 

use vars qw($VERSION);
$VERSION = '2.004'; # $Id: //depot/Tk/TixGrid/TixGrid.pm#4$

use Tk qw(Ev);

@ISA = qw(Tk::Widget);

Construct Tk::Widget 'TixGrid';

bootstrap Tk::TixGrid $Tk::VERSION; 

sub Tk_cmd { \&Tk::tixGrid }

EnterMethods Tk::TixGrid __FILE__,qw();

sub ClassInit
{
}

1;

