require Tk;
package Tk::ROText;
require Tk::Text;
@ISA = qw(Tk::Text);
Tk::Widget->Construct('ROText');

sub ClassInit
{
 my ($class,$mw) = @_;
 return $class->bindRdOnly($mw);
}

sub Tk::Widget::ScrlROText { shift->Scrolled('ROText' => @_) }

1;
