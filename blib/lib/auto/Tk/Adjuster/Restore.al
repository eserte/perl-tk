# NOTE: Derived from ./blib/lib/Tk/Adjuster.pm.  Changes made here will be lost.
package Tk::Adjuster;

sub Restore
{
 my $w = shift;
 if ($w->vert)
  {
   $w->dWidth(-$w->ReqWidth);
  }
 else
  {
   $w->dHeight(-$w->ReqHeight);
  }
}

1;
