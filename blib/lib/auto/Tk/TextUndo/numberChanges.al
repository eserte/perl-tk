# NOTE: Derived from blib/lib/Tk/TextUndo.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::TextUndo;

#line 84 "blib/lib/Tk/TextUndo.pm (autosplit into blib/lib/auto/Tk/TextUndo/numberChanges.al)"
sub numberChanges
{
 my $w = shift;
 return 0 unless exists $w->{'UNDO'};
 return scalar(@{$w->{'UNDO'}});
}

# end of Tk::TextUndo::numberChanges
1;
