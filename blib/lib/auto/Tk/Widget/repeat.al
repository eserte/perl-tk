# NOTE: Derived from ./blib/lib/Tk/Widget.pm.  Changes made here will be lost.
package Tk::Widget;

sub repeat
{
 require Tk::After;
 my $w = shift;
 my $t = shift;
 return Tk::After->new($w,$t,'repeat',@_);
}

1;
