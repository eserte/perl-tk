# NOTE: Derived from .././blib/lib/Tk/Entry.pm.  Changes made here will be lost.
package Tk::Entry;

# Transpose
# This procedure implements the "transpose" function for entry widgets.
# It tranposes the characters on either side of the insertion cursor,
# unless the cursor is at the end of the line.  In this case it
# transposes the two characters to the left of the cursor.  In either
# case, the cursor ends up to the right of the transposed characters.
#
# Arguments:
# w - The entry window.
sub Transpose
{
 my $w = shift;
 my $i = $w->index('insert');
 $i++ if ($i < $w->index('end'));
 my $first = $i-2;
 return if ($first < 0);
 my $str = $w->get;
 my $new = substr($str,$i-1,1) . substr($str,$first,1);
 $w->delete($first,$i);
 $w->insert('insert',$new);
 $w->SeeInsert;
}

1;
