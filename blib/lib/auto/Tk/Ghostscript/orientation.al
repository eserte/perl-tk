# NOTE: Derived from .././blib/lib/Tk/Ghostscript.pm.  Changes made here will be lost.
package Tk::Ghostscript;

sub orientation
{
 my $w = shift;
 if (@_)
  {
   my $view = shift;
   $w->{'page_orientation'} = $w->$view();
   $w->ChangeView;
  }
 my @names = ('Portrait','Landscape','Upsidedown','Seascape');
 return $names[$w->{'page_orientation'}/90];
}

1;
