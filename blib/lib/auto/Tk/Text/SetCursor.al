# NOTE: Derived from .././blib/lib/Tk/Text.pm.  Changes made here will be lost.
package Tk::Text;

# SetCursor
# Move the insertion cursor to a given position in a text. Also
# clears the selection, if there is one in the text, and makes sure
# that the insertion cursor is visible.
#
# Arguments:
# w - The text window.
# pos - The desired new position for the cursor in the window.
sub SetCursor
{
 my $w = shift;
 my $pos = shift;
 $pos = "end - 1 chars" if $w->compare($pos,"==",'end');
 $w->markSet('insert',$pos);
 $w->tag('remove','sel','1.0','end');
 $w->see('insert')
}

1;
