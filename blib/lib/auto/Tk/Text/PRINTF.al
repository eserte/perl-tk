# NOTE: Derived from .././blib/lib/Tk/Text.pm.  Changes made here will be lost.
package Tk::Text;

sub PRINTF
{
 my $w = shift;
 $w->PRINT(sprintf(shift,@_));
}

1;
__END__
1;
