# NOTE: Derived from ../blib/lib/Tk/Scale.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Scale;

#line 93 "../blib/lib/Tk/Scale.pm (autosplit into ../blib/lib/auto/Tk/Scale/Activate.al)"
# Activate --
# This procedure is invoked to check a given x-y position in the
# scale and activate the slider if the x-y position falls within
# the slider.
#
# Arguments:
# w - The scale widget.
# x, y - Mouse coordinates.
sub Activate
{
 my $w = shift;
 my $x = shift;
 my $y = shift;
 return if ($w->cget("-state") eq "disabled");
 my $ident = $w->identify($x,$y);
 if (defined($ident) && $ident eq 'slider')
  {
   $w->configure(-state => "active")
  }
 else
  {
   $w->configure(-state => "normal")
  }
}

# end of Tk::Scale::Activate
1;
