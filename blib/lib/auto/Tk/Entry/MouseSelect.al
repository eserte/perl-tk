# NOTE: Derived from .././blib/lib/Tk/Entry.pm.  Changes made here will be lost.
package Tk::Entry;

# MouseSelect --
# This procedure is invoked when dragging out a selection with
# the mouse. Depending on the selection mode (character, word,
# line) it selects in different-sized units. This procedure
# ignores mouse motions initially until the mouse has moved from
# one character to another or until there have been multiple clicks.
#
# Arguments:
# w - The entry window in which the button was pressed.
# x - The x-coordinate of the mouse.
sub MouseSelect
{
 my $w = shift;
 my $x = shift;
 my $cur = $w->index("@" . $x);
 my $anchor = $w->index("anchor");
 if (($cur != $anchor) || (abs($Tk::pressX - $x) >= 3))
  {
   $Tk::mouseMoved = 1
  }
 my $mode = $Tk::selectMode;
 if ($mode eq "char")
  {
   if ($Tk::mouseMoved)
    {
     if ($cur < $anchor)
      {
       $w->selection("to",$cur)
      }
     else
      {
       $w->selection("to",$cur+1)
      }
    }
  }
 elsif ($mode eq "word")
  {
   if ($cur < $w->index("anchor"))
    {
     $w->selection("range",$w->wordstart($cur),$w->wordend($anchor-1))
    }
   else
    {
     $w->selection("range",$w->wordstart($anchor),$w->wordend($cur))
    }
  }
 elsif ($mode eq "line")
  {
   $w->selection("range",0,"end")
  }
 $w->idletasks;
}

1;
