# NOTE: Derived from blib/lib/Tk.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk;

#line 626 "blib/lib/Tk.pm (autosplit into blib/lib/auto/Tk/Receive.al)"
sub Receive
{
 my $w = shift;
 warn "Receive(" . join(',',@_) .")";
 die "Tk rejects send(" . join(',',@_) .")\n";
}

# end of Tk::Receive
1;
