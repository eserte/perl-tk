# NOTE: Derived from blib/lib/Tk/TextUndo.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::TextUndo;

#line 127 "blib/lib/Tk/TextUndo.pm (autosplit into blib/lib/auto/Tk/TextUndo/Load.al)"
sub Load
{
 my ($text,$file) = @_;
 if (open(FILE,"<$file"))
  {
   $text->MainWindow->Busy;
   $text->SUPER::delete('1.0','end');
   delete $text->{UNDO};
   while (<FILE>)
    {
     $text->SUPER::insert('end',$_);
    }
   close(FILE);
   $text->markSet('insert' => '1.0');
   $text->FileName($file);
   $text->MainWindow->Unbusy;
  }
 else
  {
   $text->BackTrace("Cannot open $file:$!");
  }
}

1;
# end of Tk::TextUndo::Load
