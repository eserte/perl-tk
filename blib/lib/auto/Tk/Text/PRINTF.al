# NOTE: Derived from ../blib/lib/Tk/Text.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Text;

#line 823 "../blib/lib/Tk/Text.pm (autosplit into ../blib/lib/auto/Tk/Text/PRINTF.al)"
sub PRINTF
{
 my $w = shift;
 $w->PRINT(sprintf(shift,@_));
}

1;
__END__

1;
# end of Tk::Text::PRINTF
