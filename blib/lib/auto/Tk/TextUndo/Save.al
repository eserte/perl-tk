# NOTE: Derived from blib/lib/Tk/TextUndo.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::TextUndo;

#line 101 "blib/lib/Tk/TextUndo.pm (autosplit into blib/lib/auto/Tk/TextUndo/Save.al)"
sub Save
{
 my $text = shift;
 my $file = (@_) ? shift : $text->FileName;
 $text->BackTrace("No filename defined") unless (defined $file);
 if (open(FILE,">$file"))
  {
   my $index = '1.0';
   while ($text->compare($index,'<','end'))
    {
     my $end = $text->index("$index + 1024 chars");
     print FILE $text->get($index,$end);
     $index = $end;
    }
   if (close(FILE))
    {
     delete $text->{UNDO}; 
     $text->FileName($file);
    }
  }
 else
  {
   $text->BackTrace("Cannot open $file:$!");
  }
}

# end of Tk::TextUndo::Save
1;
