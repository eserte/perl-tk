# NOTE: Derived from ./blib/lib/Tk/TextUndo.pm.  Changes made here will be lost.
package Tk::TextUndo;

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
   $text->{FILE} = $file;
   $text->MainWindow->Unbusy;
  }
 else
  {
   $text->BackTrace("Cannot open $file:$!");
  }
}

#   Should one add/document a Filename(?$newfilename?) method, or
#   document the $text->{FILE} instance variable, or
#   leave the housekeeping to the programmer?

#   We have here no <L4> on our keyboard :-(  So TextUndo needs

#	- document the 'undo' method. so other can use Bind
#	- an BindUndo method
#	- or use/document *textUndo.undo resource (defaults
#	  to <L4>


1;
