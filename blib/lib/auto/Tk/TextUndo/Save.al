# NOTE: Derived from ./blib/lib/Tk/TextUndo.pm.  Changes made here will be lost.
package Tk::TextUndo;

sub Save
{
 my $text = shift;
 my $file = (@_) ? shift : $text->{FILE};
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
     $text->{FILE} = $file;
    }
  }
 else
  {
   $text->BackTrace("Cannot open $file:$!");
  }
}

1;
