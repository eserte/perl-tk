# NOTE: Derived from .././blib/lib/Tk/Listbox.pm.  Changes made here will be lost.
package Tk::Listbox;

# ExtendUpDown --
#
# Does nothing unless we're in extended selection mode; in this
# case it moves the location cursor (active element) up or down by
# one element, and extends the selection to that point.
#
# Arguments:
# w - The listbox widget.
# amount - +1 to move down one item, -1 to move back one item.
sub ExtendUpDown
{
 my $w = shift;
 my $amount = shift;
 if ($w->cget("-selectmode") ne "extended")
  {
   return;
  }
 $w->activate($w->index("active")+$amount);
 $w->see("active");
 $w->Motion($w->index("active"))
}

1;
