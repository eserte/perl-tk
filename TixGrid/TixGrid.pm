package Tk::TixGrid; 

use vars qw($VERSION);
$VERSION = '3.003'; # $Id: //depot/Tk8/TixGrid/TixGrid.pm#3$

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

