# NOTE: Derived from blib/lib/Tk/Adjuster.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Adjuster;

#line 222 "blib/lib/Tk/Adjuster.pm (autosplit into blib/lib/auto/Tk/Adjuster/Restore.al)"
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

# end of Tk::Adjuster::Restore
1;
