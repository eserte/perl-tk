# NOTE: Derived from .././blib/lib/Tk/Entry.pm.  Changes made here will be lost.
package Tk::Entry;

# KeySelect
# This procedure is invoked when stroking out selections using the
# keyboard. It moves the cursor to a new position, then extends
# the selection to that position.
#
# Arguments:
# w - The entry window.
# new - A new position for the insertion cursor (the cursor hasn't
# actually been moved to this position yet).
sub KeySelect
{
 my $w = shift;
 my $new = shift;
 if (!$w->selection("present"))
  {
   $w->selection("from","insert");
   $w->selection("to",$new)
  }
 else
  {
   $w->selection("adjust",$new)
  }
 $w->icursor($new);
 $w->SeeInsert;
}

1;
