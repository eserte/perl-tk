# NOTE: Derived from ./blib/lib/Tk/Frame.pm.  Changes made here will be lost.
package Tk::Frame;

sub queuePack
{
 my ($cw) = @_; 
 unless ($cw->{'pack_pending'})
  {
   $cw->{'pack_pending'} = 1;
   $cw->afterIdle([$cw,'packscrollbars']);
  }
}

1;
