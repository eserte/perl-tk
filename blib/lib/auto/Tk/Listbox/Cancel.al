# NOTE: Derived from ../blib/lib/Tk/Listbox.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Listbox;

#line 419 "../blib/lib/Tk/Listbox.pm (autosplit into ../blib/lib/auto/Tk/Listbox/Cancel.al)"
# Cancel
#
# This procedure is invoked to cancel an extended selection in
# progress. If there is an extended selection in progress, it
# restores all of the items between the active one and the anchor
# to their previous selection state.
#
# Arguments:
# w - The listbox widget.
sub Cancel
{
 my $w = shift;
 if ($w->cget("-selectmode") ne "extended")
  {
   return;
  }
 $first = $w->index("anchor");
 $last = $Prev;
 if ($first > $last)
  {
   $tmp = $first;
   $first = $last;
   $last = $tmp
  }
 $w->selectionClear($first,$last);
 while ($first <= $last)
  {
   if (Tk::lsearch(\@Selection,$first) >= 0)
    {
     $w->selectionSet($first)
    }
   $first += 1
  }
}

# end of Tk::Listbox::Cancel
1;
