# NOTE: Derived from blib/lib/Tk/Frame.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Frame;

#line 157 "blib/lib/Tk/Frame.pm (autosplit into blib/lib/auto/Tk/Frame/label.al)"
sub label
{
 my ($cw,$val) = @_;
 my $var = $cw->cget('-labelVariable');
 if (@_ > 1 && defined $val)
  {
   if (!defined $var)
    {
     $var = \$cw->{Configure}{'-label'};
     $cw->labelVariable($var);
    }
   $$var = $val;
  }
 return (defined $var) ? $$var : undef;;
}

# end of Tk::Frame::label
1;
