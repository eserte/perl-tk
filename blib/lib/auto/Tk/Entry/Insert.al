# NOTE: Derived from .././blib/lib/Tk/Entry.pm.  Changes made here will be lost.
package Tk::Entry;

# Insert --
# Insert a string into an entry at the point of the insertion cursor.
# If there is a selection in the entry, and it covers the point of the
# insertion cursor, then delete the selection before inserting.
#
# Arguments:
# w - The entry window in which to insert the string
# s - The string to insert (usually just a single character)
sub Insert
{
 my $w = shift;
 my $s = shift;
 return unless (defined $s && $s ne "");
 eval
  {local $SIG{__DIE__};
   $insert = $w->index("insert");
   if ($w->index("sel.first") <= $insert && $w->index("sel.last") >= $insert)
    {
     $w->deleteSelected
    }
  };
 $w->insert("insert",$s);
 $w->SeeInsert
}

1;
