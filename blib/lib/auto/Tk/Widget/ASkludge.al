# NOTE: Derived from blib/lib/Tk/Widget.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Widget;

#line 1106 "blib/lib/Tk/Widget.pm (autosplit into blib/lib/auto/Tk/Widget/ASkludge.al)"
sub ASkludge
{
 my ($hash,$sense) = @_;
 foreach my $key (%$hash)
  {
   if ($key =~ /-.*variable/ && ref($hash->{$key}) eq 'SCALAR')
    {
     if ($sense)
      {
       my $val = ${$hash->{$key}};
       require Tie::Scalar;
       tie ${$hash->{$key}},'Tie::StdScalar';
       ${$hash->{$key}} = $val;
      }
     else
      {
       untie ${$hash->{$key}};
      }
    }
  }
}

# end of Tk::Widget::ASkludge
1;
