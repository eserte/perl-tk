# NOTE: Derived from ../blib/lib/Tk/Text.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Text;

#line 637 "../blib/lib/Tk/Text.pm (autosplit into ../blib/lib/auto/Tk/Text/UpDownLine.al)"
# UpDownLine --
# Returns the index of the character one line above or below the
# insertion cursor. There are two tricky things here. First,
# we want to maintain the original column across repeated operations,
# even though some lines that will get passed through do not have
# enough characters to cover the original column. Second, do not
# try to scroll past the beginning or end of the text.
#
# Arguments:
# w - The text window in which the cursor is to move.
# n - The number of lines to move: -1 for up one line,
# +1 for down one line.
sub UpDownLine
{
 my $w = shift;
 my $n = shift;
 my $i = $w->index('insert');
 my ($line,$char) = split(/\./,$i);
 if (!defined($Tk::prevPos) || $Tk::prevPos ne $i)
  {
   $Tk::char = $char
  }
 my $new = $w->index($line+$n . "." . $Tk::char);
 if ($w->compare($new,"==",'end') || $w->compare($new,"==","insert linestart"))
  {
   $new = $i
  }
 $Tk::prevPos = $new;
 return $new;
}

# end of Tk::Text::UpDownLine
1;
