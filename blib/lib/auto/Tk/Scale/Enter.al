# NOTE: Derived from .././blib/lib/Tk/Scale.pm.  Changes made here will be lost.
package Tk::Scale;

sub Enter
{
 my ($w,$x,$y) = @_;
 if ($Tk::strictMotif)
  {
   $w->{'activeBg'} = $w->cget("-activebackground");
   $w->configure("-activebackground",$w->cget("-background"));
  }
 $w->Activate($x,$y);
}

1;
