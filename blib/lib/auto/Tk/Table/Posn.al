# NOTE: Derived from blib/lib/Tk/Table.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Table;

#line 493 "blib/lib/Tk/Table.pm (autosplit into blib/lib/auto/Tk/Table/Posn.al)"
sub Posn
{
 my ($t,$s) = @_;
 my $info   = $t->{Slave}{$s->PathName};
 return (wantarray) ? @$info : $info;
}

# end of Tk::Table::Posn
1;
