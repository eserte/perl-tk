# NOTE: Derived from .././blib/lib/Tk/Scrollbar.pm.  Changes made here will be lost.
package Tk::Scrollbar;

sub Leave
{
 my $w = shift;
 if ($Tk::strictMotif)
  {
   $w->configure("-activebackground" => $activeBg) if (defined $activeBg) ;
  }
 $w->activate("");
}

1;
