# NOTE: Derived from ../blib/lib/Tk/Text.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Text;

#line 663 "../blib/lib/Tk/Text.pm (autosplit into ../blib/lib/auto/Tk/Text/PrevPara.al)"
# PrevPara --
# Returns the index of the beginning of the paragraph just before a given
# position in the text (the beginning of a paragraph is the first non-blank
# character after a blank line).
#
# Arguments:
# w - The text window in which the cursor is to move.
# pos - Position at which to start search.
sub PrevPara
{
 my $w = shift;
 my $pos = shift;
 $pos = $w->index("$pos linestart");
 while (1)
  {
   if ($w->get("$pos - 1 line") eq "\n" && $w->get($pos) ne "\n" || $pos eq '1.0' )
    {
     my $string = $w->get($pos,"$pos lineend");
     if ($string =~ /^(\s)+/)
      {
       my $off = length($1);
       $pos = $w->index("$pos + $off chars")
      }
     if ($w->compare($pos,"!=",'insert') || $pos eq '1.0')
      {
       return $pos;
      }
    }
   $pos = $w->index("$pos - 1 line")
  }
}

# end of Tk::Text::PrevPara
1;
