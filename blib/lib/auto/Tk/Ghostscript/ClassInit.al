# NOTE: Derived from .././blib/lib/Tk/Ghostscript.pm.  Changes made here will be lost.
package Tk::Ghostscript;

sub ClassInit
{
 my ($class,$mw) = @_;
 $mw->bind($class,'<Configure>','NoteSize');
 $mw->bind($class,'<Destroy>','StopInterp');
 return $class;
}

1;

1;
