# NOTE: Derived from blib/lib/Tk/Frame.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Frame;

#line 191 "blib/lib/Tk/Frame.pm (autosplit into blib/lib/auto/Tk/Frame/freeze_on_map.al)"
sub freeze_on_map
{
 my ($w) = @_;
 unless ($w->Tk::bind('Freeze','<Map>'))
  {
   $w->Tk::bind('Freeze','<Map>',['packPropagate' => 0])
  }
 $w->AddBindTag('Freeze');
}

# end of Tk::Frame::freeze_on_map
1;
