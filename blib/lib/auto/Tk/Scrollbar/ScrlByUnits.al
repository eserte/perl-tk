# NOTE: Derived from .././blib/lib/Tk/Scrollbar.pm.  Changes made here will be lost.
package Tk::Scrollbar;

# tkScrlByUnits --
# This procedure tells the scrollbar's associated widget to scroll up
# or down by a given number of units.  It notifies the associated widget
# in different ways for old and new command syntaxes.
#
# Arguments:
# w -		The scrollbar widget.
# orient -	Which kinds of scrollbars this applies to:  "h" for
#		horizontal, "v" for vertical, "hv" for both.
# amount -	How many units to scroll:  typically 1 or -1.

sub ScrlByUnits 
{my $w = shift;
 my $orient = shift;
 my $amount = shift;
 my $cmd    = $w->cget("-command");
 return unless (defined $cmd);
 return if (index($orient,substr($w->cget("-orient"),0,1)) < 0); 
 my @info = $w->get;
 if (@info == 2)
  {
   $cmd->Call("scroll",$amount,"units");
  }
 else
  {
   $cmd->Call($info[2]+$amount);
  }
}

1;
