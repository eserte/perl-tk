# NOTE: Derived from ./blib/lib/Tk/Table.pm.  Changes made here will be lost.
package Tk::Table;

sub Posn
{
 my ($t,$s) = @_;
 my $info   = $t->{Slave}{$s->PathName};
 return (wantarray) ? @$info : $info;
}

1;
