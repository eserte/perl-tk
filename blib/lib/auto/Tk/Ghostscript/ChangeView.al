# NOTE: Derived from .././blib/lib/Tk/Ghostscript.pm.  Changes made here will be lost.
package Tk::Ghostscript;

sub ChangeView
{
 my $w = shift;
 my ($llx,$lly,$urx,$ury) = @{$w->{'BoundingBox'}};
 my $x = int(($urx - $llx)*$w->{'x_pixels_per_inch'}/72.0);
 my $y = int(($ury - $lly)*$w->{'y_pixels_per_inch'}/72.0);
 $w->StopInterp;
 if ($w->{'page_orientation'} % 180 == 0)
  {
   $w->configure('-width' => $x,'-height' => $y);
  }
 else
  {
   $w->configure('-width' => $y,'-height' => $x);
  }
}

1;
