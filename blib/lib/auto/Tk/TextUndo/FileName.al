# NOTE: Derived from blib/lib/Tk/TextUndo.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::TextUndo;

#line 91 "blib/lib/Tk/TextUndo.pm (autosplit into blib/lib/auto/Tk/TextUndo/FileName.al)"
sub FileName
{
 my $text = shift;
 if (@_)
  {
   $text->{'FILE'} = shift; 
  }
 return $text->{'FILE'};
}

# end of Tk::TextUndo::FileName
1;
