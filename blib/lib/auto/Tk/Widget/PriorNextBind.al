# NOTE: Derived from ./blib/lib/Tk/Widget.pm.  Changes made here will be lost.
package Tk::Widget;

sub PriorNextBind
{
 my ($mw,$class) = @_;
 $mw->bind($class,'<Next>',     ['yview','scroll',1,'pages']);
 $mw->bind($class,'<Prior>',    ['yview','scroll',-1,'pages']);
}

1;
