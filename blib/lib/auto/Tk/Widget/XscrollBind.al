# NOTE: Derived from ./blib/lib/Tk/Widget.pm.  Changes made here will be lost.
package Tk::Widget;

sub XscrollBind
{
 my ($mw,$class) = @_;
 $mw->bind($class,'<Left>',         ['xview','scroll',-1,'units']);
 $mw->bind($class,'<Control-Left>', ['xview','scroll',-1,'pages']);
 $mw->bind($class,'<Control-Prior>',['xview','scroll',-1,'pages']);
 $mw->bind($class,'<Right>',        ['xview','scroll',1,'units']);
 $mw->bind($class,'<Control-Right>',['xview','scroll',1,'pages']);
 $mw->bind($class,'<Control-Next>', ['xview','scroll',1,'pages']);

 $mw->bind($class,'<Home>',         ['xview','moveto',0]);
 $mw->bind($class,'<End>',          ['xview','moveto',1]);
}

1;
