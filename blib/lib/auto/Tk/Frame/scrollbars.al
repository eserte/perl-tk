# NOTE: Derived from blib/lib/Tk/Frame.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Frame;

#line 323 "blib/lib/Tk/Frame.pm (autosplit into blib/lib/auto/Tk/Frame/scrollbars.al)"
sub scrollbars
{
 my ($cw,$opt) = @_;
 my $var = \$cw->{'-scrollbars'};
 if (@_ > 1)
  {
   my $old = $$var;
   if (!defined $old || $old ne $opt)
    {
     $$var = $opt;
     $cw->queuePack;
    }
  }
 return $$var;
}

# end of Tk::Frame::scrollbars
1;
