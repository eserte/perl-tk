# NOTE: Derived from .././blib/lib/Tk/Entry.pm.  Changes made here will be lost.
package Tk::Entry;

# Backspace --
# Backspace over the character just before the insertion cursor.
#
# Arguments:
# w - The entry window in which to backspace.
sub Backspace
{
 my $w = shift;
 if ($w->selection("present"))
  {
   $w->deleteSelected
  }
 else
  {
   my $x = $w->index("insert")-1;
   $w->delete($x) if ($x >= 0);
  }
}

1;
