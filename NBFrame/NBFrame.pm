package Tk::NBFrame; 
require Tk;
require DynaLoader;

@ISA = qw(DynaLoader Tk::Widget);

Tk::Widget->Construct('NBFrame');

bootstrap Tk::NBFrame $Tk::VERSION; 

sub Tk_cmd { \&Tk::nbframe }

EnterMethods Tk::NBFrame __FILE__,qw(activate add delete
				     focus info 
				     geometryinfo identify move pagecget
				     pageconfigure);
1;

