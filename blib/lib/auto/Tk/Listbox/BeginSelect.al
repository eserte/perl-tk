# NOTE: Derived from .././blib/lib/Tk/Listbox.pm.  Changes made here will be lost.
package Tk::Listbox;

# BeginSelect --
#
# This procedure is typically invoked on button-1 presses. It begins
# the process of making a selection in the listbox. Its exact behavior
# depends on the selection mode currently in effect for the listbox;
# see the Motif documentation for details.
#
# Arguments:
# w - The listbox widget.
# el - The element for the selection operation (typically the
# one under the pointer). Must be in numerical form.
sub BeginSelect
{
 my $w = shift;
 my $el = shift;
 if ($w->cget("-selectmode") eq "multiple")
  {
   if ($w->selectionIncludes($el))
    {
     $w->selectionClear($el)
    }
   else
    {
     $w->selectionSet($el)
    }
  }
 else
  {
   $w->selectionClear(0,"end");
   $w->selectionSet($el);
   $w->selectionAnchor($el);
   @Selection = ();
   $Prev = $el
  }
}

1;
