package Tk::TixGrid; 
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

