# NOTE: Derived from blib/lib/Tk/Table.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Table;

#line 474 "blib/lib/Tk/Table.pm (autosplit into blib/lib/auto/Tk/Table/Create.al)"
sub Create
{
 my $t = shift;
 my $r = shift;
 my $c = shift;
 my $kind = shift;
 $t->put($r,$c,$t->$kind(@_));
}

# end of Tk::Table::Create
1;
