# NOTE: Derived from ./blib/lib/Tk.pm.  Changes made here will be lost.
package Tk;

sub Receive
{
 my $w = shift;
 warn "Receive(" . join(',',@_) .")";
 die "Tk rejects send(" . join(',',@_) .")\n";
}

1;
