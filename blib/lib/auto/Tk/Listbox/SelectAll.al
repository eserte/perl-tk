# NOTE: Derived from ../blib/lib/Tk/Listbox.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Listbox;

#line 452 "../blib/lib/Tk/Listbox.pm (autosplit into ../blib/lib/auto/Tk/Listbox/SelectAll.al)"
# SelectAll
#
# This procedure is invoked to handle the "select all" operation.
# For single and browse mode, it just selects the active element.
# Otherwise it selects everything in the widget.
#
# Arguments:
# w - The listbox widget.
sub SelectAll
{
 my $w = shift;
 my $mode = $w->cget("-selectmode");
 if ($mode eq "single" || $mode eq "browse")
  {
   $w->selectionClear(0,"end");
   $w->selectionSet("active")
  }
 else
  {
   $w->selectionSet(0,"end")
  }
}

# end of Tk::Listbox::SelectAll
1;
