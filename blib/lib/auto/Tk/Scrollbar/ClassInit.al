# NOTE: Derived from ../blib/lib/Tk/Scrollbar.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Tk::Scrollbar;

#line 35 "../blib/lib/Tk/Scrollbar.pm (autosplit into ../blib/lib/auto/Tk/Scrollbar/ClassInit.al)"
sub ClassInit
{
 my ($class,$mw) = @_;
 $mw->bind($class, "<Enter>", "Enter");
 $mw->bind($class, "<Motion>", "Motion");
 $mw->bind($class, "<Leave>", "Leave");

 $mw->bind($class, "<1>", "ButtonDown");
 $mw->bind($class, "<B1-Motion>", "Drag");
 $mw->bind($class, "<ButtonRelease-1>", "ButtonUp");
 $mw->bind($class, "<B1-Leave>", 'NoOp'); # prevent generic <Leave>
 $mw->bind($class, "<B1-Enter>", 'NoOp'); # prevent generic <Enter>
 $mw->bind($class, "<Control-1>", "ScrlTopBottom"); 

 $mw->bind($class, "<2>", "ButtonDown");
 $mw->bind($class, "<B2-Motion>", "Drag");
 $mw->bind($class, "<ButtonRelease-2>", "ButtonUp");
 $mw->bind($class, "<B2-Leave>", 'NoOp'); # prevent generic <Leave>
 $mw->bind($class, "<B2-Enter>", 'NoOp'); # prevent generic <Enter>
 $mw->bind($class, "<Control-2>", "ScrlTopBottom"); 

 $mw->bind($class, "<Up>",            ["ScrlByUnits","v",-1]);
 $mw->bind($class, "<Down>",          ["ScrlByUnits","v", 1]);
 $mw->bind($class, "<Control-Up>",    ["ScrlByPages","v",-1]);
 $mw->bind($class, "<Control-Down>",  ["ScrlByPages","v", 1]);

 $mw->bind($class, "<Left>",          ["ScrlByUnits","h",-1]);
 $mw->bind($class, "<Right>",         ["ScrlByUnits","h", 1]);
 $mw->bind($class, "<Control-Left>",  ["ScrlByPages","h",-1]);
 $mw->bind($class, "<Control-Right>", ["ScrlByPages","h", 1]);

 $mw->bind($class, "<Prior>",         ["ScrlByPages","hv",-1]);
 $mw->bind($class, "<Next>",          ["ScrlByPages","hv", 1]);

 $mw->bind($class, "<Home>",          ["ScrlToPos", 0]);
 $mw->bind($class, "<End>",           ["ScrlToPos", 1]);

 return $class;

}

# end of Tk::Scrollbar::ClassInit
1;
