# simply split out of Tk-a5's Tk.pm
package Tk::Label; 
require Tk;

@ISA = qw(Tk::Widget); 

Tk::Widget->Construct('Label');

sub Tk_cmd { \&Tk::label }

sub classinit
{
 my ($class,$mw) = @_;
 return $class;
}

1;



