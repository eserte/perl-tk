# NOTE: Derived from .././blib/lib/Tk/Text.pm.  Changes made here will be lost.
package Tk::Text;

# SelectTo --
# This procedure is invoked to extend the selection, typically when
# dragging it with the mouse. Depending on the selection mode (character,
# word, line) it selects in different-sized units. This procedure
# ignores mouse motions initially until the mouse has moved from
# one character to another or until there have been multiple clicks.
#
# Arguments:
# w - The text window in which the button was pressed.
# index - Index of character at which the mouse button was pressed.
sub SelectTo
{
 my $w = shift;
 my $index = shift;
 $Tk::selectMode = shift if (@_);
 my $cur = $w->index($index);
 my $anchor = Tk::catch { $w->index('anchor') };
 if (!defined $anchor)
  {
   $w->markSet('anchor',$anchor = $cur);
   $Tk::mouseMoved = 0;
  }
 elsif ($w->compare($cur,"!=",$anchor))
  {
   $Tk::mouseMoved = 1;
  }
 $Tk::selectMode = 'char' unless (defined $Tk::selectMode);
 my $mode = $Tk::selectMode;
 my ($first,$last);
 if ($mode eq 'char')
  {
   if ($w->compare($cur,"<",'anchor'))
    {
     $first = $cur;
     $last = 'anchor';
    }
   else
    {
     $first = 'anchor';
     $last = $cur
    }
  }
 elsif ($mode eq 'word')
  {
   if ($w->compare($cur,"<",'anchor'))
    {
     $first = $w->index("$cur wordstart");
     $last = $w->index("anchor - 1c wordend")
    }
   else
    {
     $first = $w->index("anchor wordstart");
     $last = $w->index("$cur wordend")
    }
  }
 elsif ($mode eq 'line')
  {
   if ($w->compare($cur,"<",'anchor'))
    {
     $first = $w->index("$cur linestart");
     $last = $w->index("anchor - 1c lineend + 1c")
    }
   else
    {
     $first = $w->index("anchor linestart");
     $last = $w->index("$cur lineend + 1c")
    }
  }
 if ($Tk::mouseMoved || $Tk::selectMode ne 'char')
  {
   $w->tag('remove','sel','1.0',$first);
   $w->tag('add','sel',$first,$last);
   $w->tag('remove','sel',$last,'end');
   $w->idletasks;
  }
}

1;
