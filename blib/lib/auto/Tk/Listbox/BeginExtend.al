# NOTE: Derived from ../blib/lib/Tk/Listbox.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Listbox;

#line 251 "../blib/lib/Tk/Listbox.pm (autosplit into ../blib/lib/auto/Tk/Listbox/BeginExtend.al)"
# BeginExtend --
#
# This procedure is typically invoked on shift-button-1 presses. It
# begins the process of extending a selection in the listbox. Its
# exact behavior depends on the selection mode currently in effect
# for the listbox; see the Motif documentation for details.
#
# Arguments:
# w - The listbox widget.
# el - The element for the selection operation (typically the
# one under the pointer). Must be in numerical form.
sub BeginExtend
{
 my $w = shift;
 my $el = shift;
 if ($w->cget("-selectmode") eq "extended" && $w->selectionIncludes("anchor"))
  {
   $w->Motion($el)
  }
}

# end of Tk::Listbox::BeginExtend
1;
