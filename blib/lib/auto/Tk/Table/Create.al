# NOTE: Derived from ./blib/lib/Tk/Table.pm.  Changes made here will be lost.
package Tk::Table;

sub Create
{
 my $t = shift;
 my $r = shift;
 my $c = shift;
 my $kind = shift;
 $t->put($r,$c,$t->$kind(@_));
}

1;
