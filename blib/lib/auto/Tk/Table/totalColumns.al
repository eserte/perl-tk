# NOTE: Derived from ./blib/lib/Tk/Table.pm.  Changes made here will be lost.
package Tk::Table;

sub totalColumns
{
 scalar @{shift->{'Width'}};
}

1;
