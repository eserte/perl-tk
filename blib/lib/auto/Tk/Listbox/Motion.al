# NOTE: Derived from .././blib/lib/Tk/Listbox.pm.  Changes made here will be lost.
package Tk::Listbox;

# Motion --
#
# This procedure is called to process mouse motion events while
# button 1 is down. It may move or extend the selection, depending
# on the listbox's selection mode.
#
# Arguments:
# w - The listbox widget.
# el - The element under the pointer (must be a number).
sub Motion
{
 my $w = shift;
 my $el = shift;
 if (defined($Prev) && $el == $Prev)
  {
   return;
  }
 $anchor = $w->index("anchor");
 my $mode = $w->cget("-selectmode");
 if ($mode eq "browse")
  {
   $w->selectionClear(0,"end");
   $w->selectionSet($el);
   $Prev = $el;
  }
 elsif ($mode eq "extended")
  {
   $i = $Prev;
   if ($w->selectionIncludes('anchor'))
    {
     $w->selectionClear($i,$el);
     $w->selectionSet("anchor",$el)
    }
   else
    {
     $w->selectionClear($i,$el);
     $w->selectionClear("anchor",$el)
    }
   while ($i < $el && $i < $anchor)
    {
     if (Tk::lsearch(\@Selection,$i) >= 0)
      {
       $w->selectionSet($i)
      }
     $i += 1
    }
   while ($i > $el && $i > $anchor)
    {
     if (Tk::lsearch(\@Selection,$i) >= 0)
      {
       $w->selectionSet($i)
      }
     $i += -1
    }
   $Prev = $el
  }
}

1;
