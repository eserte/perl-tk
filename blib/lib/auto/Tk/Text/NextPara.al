# NOTE: Derived from .././blib/lib/Tk/Text.pm.  Changes made here will be lost.
package Tk::Text;

# NextPara --
# Returns the index of the beginning of the paragraph just after a given
# position in the text (the beginning of a paragraph is the first non-blank
# character after a blank line).
#
# Arguments:
# w - The text window in which the cursor is to move.
# start - Position at which to start search.
sub NextPara
{
 my $w = shift;
 my $start = shift;
 my $pos = $w->index("$start linestart + 1 line");
 while ($w->get($pos) ne "\n")
  {
   if ($w->compare($pos,"==",'end'))
    {
     return $w->index("end - 1c");
    }
   $pos = $w->index("$pos + 1 line")
  }
 while ($w->get($pos) eq "\n" )
  {
   $pos = $w->index("$pos + 1 line");
   if ($w->compare($pos,"==",'end'))
    {
     return $w->index("end - 1c");
    }
  }
 my $string = $w->get($pos,"$pos lineend");
 if ($string =~ /^(\s+)/)
  {
   my $off = length($1);
   return $w->index("$pos + $off chars");
  }
 return $pos;
}

1;
