# NOTE: Derived from ../blib/lib/Tk/Text.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Text;

#line 808 "../blib/lib/Tk/Text.pm (autosplit into ../blib/lib/auto/Tk/Text/TIEHANDLE.al)"
sub TIEHANDLE
{
 my ($class,$obj) = @_;
 return $obj;
}

# end of Tk::Text::TIEHANDLE
1;
