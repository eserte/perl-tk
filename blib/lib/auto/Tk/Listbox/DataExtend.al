# NOTE: Derived from .././blib/lib/Tk/Listbox.pm.  Changes made here will be lost.
package Tk::Listbox;

# DataExtend
#
# This procedure is called for key-presses such as Shift-KEndData.
# If the selection mode isn't multiple or extend then it does nothing.
# Otherwise it moves the active element to el and, if we're in
# extended mode, extends the selection to that point.
#
# Arguments:
# w - The listbox widget.
# el - An integer element number.
sub DataExtend
{
 my $w = shift;
 my $el = shift;
 $mode = $w->cget("-selectmode");
 if ($mode eq "extended")
  {
   $w->activate($el);
   $w->see($el);
   if ($w->selectionIncludes("anchor"))
    {
     $w->Motion($el)
    }
  }
 elsif ($mode eq "multiple")
  {
   $w->activate($el);
   $w->see($el)
  }
}

1;
