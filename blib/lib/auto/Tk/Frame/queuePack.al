# NOTE: Derived from blib/lib/Tk/Frame.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Frame;

#line 173 "blib/lib/Tk/Frame.pm (autosplit into blib/lib/auto/Tk/Frame/queuePack.al)"
sub queuePack
{
 my ($cw) = @_; 
 unless ($cw->{'pack_pending'})
  {
   $cw->{'pack_pending'} = 1;
   $cw->afterIdle([$cw,'packscrollbars']);
  }
}

# end of Tk::Frame::queuePack
1;
