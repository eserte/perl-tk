# NOTE: Derived from .././blib/lib/Tk/Listbox.pm.  Changes made here will be lost.
package Tk::Listbox;

# UpDown --
#
# Moves the location cursor (active element) up or down by one element,
# and changes the selection if we're in browse or extended selection
# mode.
#
# Arguments:
# w - The listbox widget.
# amount - +1 to move down one item, -1 to move back one item.
sub UpDown
{
 my $w = shift;
 my $amount = shift;
 $w->activate($w->index("active")+$amount);
 $w->see("active");
 $LNet__0 = $w->cget("-selectmode");
 if ($LNet__0 eq "browse")
  {
   $w->selectionClear(0,"end");
   $w->selectionSet("active")
  }
 elsif ($LNet__0 eq "extended")
  {
   $w->selectionClear(0,"end");
   $w->selectionSet("active");
   $w->selectionAnchor("active");
   $Prev = $w->index("active");
   @Selection = ();
  }
}

1;
