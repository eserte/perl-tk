# NOTE: Derived from ../blib/lib/Tk/Text.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Text;

#line 763 "../blib/lib/Tk/Text.pm (autosplit into ../blib/lib/auto/Tk/Text/Destroy.al)"
sub Destroy
{
 my $w = shift;
 delete $w->{_Tags_};
}

# end of Tk::Text::Destroy
1;
