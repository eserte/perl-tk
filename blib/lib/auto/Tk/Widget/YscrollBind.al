# NOTE: Derived from ./blib/lib/Tk/Widget.pm.  Changes made here will be lost.
package Tk::Widget;

sub YscrollBind
{
 my ($mw,$class) = @_;
 $mw->PriorNextBind($class);
 $mw->bind($class,'<Up>',       ['yview','scroll',-1,'units']);
 $mw->bind($class,'<Down>',     ['yview','scroll',1,'units']);
}

1;
