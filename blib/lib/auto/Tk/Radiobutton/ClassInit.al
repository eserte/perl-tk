# NOTE: Derived from ./blib/lib/Tk/Radiobutton.pm.  Changes made here will be lost.
package Tk::Radiobutton;

sub ClassInit
{
 my ($class,$mw) = @_;
 $mw->bind($class,"<Enter>", "Enter");
 $mw->bind($class,"<Leave>", "Leave");
 $mw->bind($class,"<1>", "Invoke");
 $mw->bind($class,"<space>", "Invoke");
 return $class;
}

1;
