# NOTE: Derived from .././blib/lib/Tk/Scale.pm.  Changes made here will be lost.
package Tk::Scale;

# Increment --
# This procedure is invoked to increment the value of a scale and
# to set up auto-repeating of the action if that is desired. The
# way the value is incremented depends on the "dir" and "big"
# arguments.
#
# Arguments:
# w - The scale widget.
# dir - "up" means move value towards -from, "down" means
# move towards -to.
# big - Size of increments: "big" or "little".
# repeat - Whether and how to auto-repeat the action: "noRepeat"
# means don't auto-repeat, "initial" means this is the
# first action in an auto-repeat sequence, and "again"
# means this is the second repetition or later.
sub Increment
{
 my $w = shift;
 my $dir = shift;
 my $big = shift;
 my $repeat = shift;
 my $inc;
 if ($big eq "big")
  {
   $inc = $w->cget("-bigincrement");
   if ($inc == 0)
    {
     $inc = abs(($w->cget("-to")-$w->cget("-from")))/10.0
    }
   if ($inc < $w->cget("-resolution"))
    {
     $inc = $w->cget("-resolution")
    }
  }
 else
  {
   $inc = $w->cget("-resolution")
  }
 if (($w->cget("-from") > $w->cget("-to")) ^ ($dir eq "up"))
  {
   $inc = -$inc
  }
 $w->set($w->get()+$inc);
 if ($repeat eq "again")
  {
   $w->RepeatId($w->after($w->cget("-repeatinterval"),"Increment",$w,$dir,$big,"again"));
  }
 elsif ($repeat eq "initial")
  {
   $w->RepeatId($w->after($w->cget("-repeatdelay"),"Increment",$w,$dir,$big,"again"));
  }
}

1;
