# NOTE: Derived from ./blib/lib/Tk/Frame.pm.  Changes made here will be lost.
package Tk::Frame;

sub freeze_on_map
{
 my ($w) = @_;
 unless ($w->Tk::bind('Freeze','<Map>'))
  {
   $w->Tk::bind('Freeze','<Map>',['packPropagate' => 0])
  }
 $w->AddBindTag('Freeze');
}

1;
