# NOTE: Derived from .././blib/lib/Tk/Entry.pm.  Changes made here will be lost.
package Tk::Entry;

# SetCursor
# Move the insertion cursor to a given position in an entry. Also
# clears the selection, if there is one in the entry, and makes sure
# that the insertion cursor is visible.
#
# Arguments:
# w - The entry window.
# pos - The desired new position for the cursor in the window.
sub SetCursor
{
 my $w = shift;
 my $pos = shift;
 $w->icursor($pos);
 $w->SelectionClear;
 $w->SeeInsert;
}

1;
