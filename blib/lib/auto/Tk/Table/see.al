# NOTE: Derived from blib/lib/Tk/Table.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Table;

#line 500 "blib/lib/Tk/Table.pm (autosplit into blib/lib/auto/Tk/Table/see.al)"
sub see
{
 my $t = shift;
 my ($row,$col) = (@_ == 2) ? @_ : @{$t->{Slave}{$_[0]->PathName}};
 my $see = 1;
 if (($row -= $t->cget('-fixedrows')) >= 0)
  {
   if ($row < $t->{Top})
    {
     $t->{Top} = $row;
     $t->QueueLayout(4);
     $see = 0;
    }
   elsif ($row >= $t->{Bottom})
    {
     $t->{Top} += ($row - $t->{Bottom}+1);
     $t->QueueLayout(4);
     $see = 0;
    }
  }
 if (($col -= $t->cget('-fixedcolumns')) >= 0)
  {
   if ($col < $t->{Left})
    {
     $t->{Left} = $col;
     $t->QueueLayout(4);
     $see = 0;
    }
   elsif ($col >= $t->{Right})
    {
     $t->{Left} += ($col - $t->{Right}+1);
     $t->QueueLayout(4);
     $see = 0;
    }
  }
 return $see;
}

1;
# end of Tk::Table::see
