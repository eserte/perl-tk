# simply split out of Tk-a5's Tk.pm
package Tk::Message;
use AutoLoader;

@ISA = qw(Tk::Widget);

Tk::Widget->Construct('Message');

sub Tk_cmd { \&Tk::message }

1;
__END__


